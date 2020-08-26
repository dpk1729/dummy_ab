using DataFrames, Distributed

addprocs(4)

df = DataFrame(a = collect(1:64), b= collect(65:128))

jobs    = RemoteChannel(()->Channel{DataFrameRow}(32))
results = RemoteChannel(()->Channel{Tuple{DataFrameRow{DataFrame,DataFrames.Index},Float64}}(32))


function do_work(jobs, results)
   while isready(jobs)
       job_id = take!(jobs)
       exec_time = rand()
       # sleep(exec_time)
       put!(results, (job_id, exec_time))

   end
end

function make_jobs(n)
   for i in 1:n
       put!(jobs, df[i,:])
       do_work(jobs, results)
   end
end;

n = 32;

make_jobs(n)

for p in workers() # Start tasks on the workers to process requests in parallel.
   @async remote_do(do_work, jobs, results) # Similar to remotecall.
end


@elapsed while n > 0
   job_id, exec_time = take!(results)
   global n
   println("$job_id finished in $(round(exec_time;digits=2)) seconds")
   n = n - 1
end
