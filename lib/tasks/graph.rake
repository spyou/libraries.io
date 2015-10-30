namespace :graph do
  task populate: :environment do
    platform = 'Cargo'
    projects = Project.platform(platform)
    node_ids = {}
    @graph = Graph.new
    projects.each do |project|
      name = project.name

      puts name

      id = node_ids[name]
      id = node_ids[name] = @graph.add_project(platform, name) if id.nil?

      latest = project.latest_version

      latest.dependencies.each do |dep|
        next if dep.project.nil?
        puts "Dependency: #{dep.project.name}"
        dep_id = node_ids[dep.project.name]
        dep_id = node_ids[dep.project.name] = @graph.add_project(platform, dep.project.name) if dep_id.nil?

        @graph.add_dependency(id, dep_id, dep.requirements)
      end

      p node_ids
    end
  end
end
