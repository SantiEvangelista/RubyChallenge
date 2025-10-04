# app/actions/get_job_status.rb
require_relative '../jobs/product_job'

module Actions
  class GetJobStatus
    def self.call(job_id)
      result = Jobs::ProductJob.get_status(job_id)
      
      if result
        result
      else
        { error: "Job not found" }
      end
    end
  end
end
