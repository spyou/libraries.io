module Sources
  module Cargo
    class Project
      include Utilities
      attr_accessor :name, :data

      def initialize(name, data = {})
        @name = name
        @data = data
        download_data if @data.blank?
      end

      def download_data
        json = get("https://crates.io/api/v1/crates/#{name}")
        @data = json['crate']
        @data['versions'] = json['versions']
      end

      def homepage
        data['homepage']
      end

      def description
        data['description']
      end

      def keywords_array
         Array.wrap(data['keywords'])
      end

      def licenses
        data['license']
      end

      def repository_url
        repo_fallback(data['repository'], data['homepage'])
      end

      def versions
        data["versions"].map do |version|
          {
            :number => version['num'],
            :published_at => version['created_at']
          }
        end
      end

      def self.all_projects
        page = 1
        projects = []
        while true
          r = get("https://crates.io/api/v1/crates?page=#{page}&per_page=100")['crates']
          break if r == []
          projects += r
          page +=1
        end
        projects.map { |project| new(project['name'], project) }
      end

      def self.recent_projects
        # load summary json
      end
    end
  end
end
