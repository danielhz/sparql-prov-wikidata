bench_dependencies = []

%w{fuseki virtuoso}.each do |engine|
  %w{star minus union}.each do |template|
    %w{03 06}.each do |size|
      %w{B R P}.each do |mode|
        task_name = "bench_#{engine}_#{template}_#{size}_#{mode}"

        desc "Run bench for engine=#{engine}, template=#{template}, size=#{size}, mode=#{mode}"
        named_task task_name do
          case engine
          when 'fuseki'
            endpoint = LXDFusekiEndpoint.new("wikidata-20200127-fuseki3-ubuntu2004")
          when 'virtuoso'
            endpoint = LXDVirtuosoEndpoint.new("wikidata-20200127-virtuoso7-debian9")
          end
          wikidata_bench(endpoint, template, size, mode)
        end

        bench_dependencies.append(task_dependency(task_name))
      end
    end
  end
end

desc 'Run bench'
task :bench => bench_dependencies
