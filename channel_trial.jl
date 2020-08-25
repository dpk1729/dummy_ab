jobs    = Channel{Int}(32)
results = Channel{Tuple}(32)


function do_work(jobs, results)
   for job_id in jobs
       exec_time = rand()
       sleep(exec_time)
       put!(results, (job_id, exec_time))
   end
end

function make_jobs(n)
   for i in 1:n
       put!(jobs, i)
   end
end;

n = 12;

make_jobs(n)

do_work(jobs, results)

@elapsed while n > 0
   job_id, exec_time, where = take!(results)
   global n
   println("$job_id finished in $(round(exec_time;digits=2)) seconds on worker $where")
   n = n - 1
end
