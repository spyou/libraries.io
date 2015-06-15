class Repositories
  class Catalogue
    def self.index
      Repositories::Base.get_json("https://api.nuget.org/v3/catalog0/index.json")
    end

    def self.pages(since='2010-01-01', &block)
      index['items'].each do |item|
        next unless Time.parse(item['commitTimeStamp']) >= Time.parse(since)
        yield Page.new(item)
      end
    end
  end

  class Page
    def initialize(data)
      @page = Repositories::Base.get_json(data['@id'])
    end

    def packages(since='2010-01-01', &block)
      @page['items'].each do |item|
        next unless Time.parse(item['commitTimeStamp']) > Time.parse(since)
        yield Package.new(item['@id'])
      end
    end
  end

  class Package
    def initialize(url)
      @data = Repositories::Base.get_json(url)
    end

    def name
      @data['id']
    end

    def to_h
      {
        name: @data['id'],
        description: description,
        homepage: @data['projectUrl'],
        keywords_array: tags,
        repository_url: project_url
      }
    end

    def versions
      [{ number: @data['version'], published_at: @data['published'] }]
    end

    private

    def description
      @data['description'].blank? ? @data['summary'] : @data['description']
    end

    def tags
      Array(@data['tags'])
    end

    def project_url
      Repositories::Base.repo_fallback('', @data['projectUrl'])
    end
  end

  class NuGet < Base
    HAS_VERSIONS = true
    HAS_DEPENDENCIES = true
    URL = 'https://www.nuget.org'
    COLOR = '#178600'

    class << self
      def import
        Catalogue.pages do |page|
          page.packages do |package|
            project = Project.find_or_initialize_by({name: package.name, platform: self.name.demodulize})
            if project.new_record?
              project.assign_attributes(package.to_h.except(:name))
              project.save
            else
              project.update_attributes(package.to_h.except(:name))
            end
            package.versions.each do |version|
              project.versions.find_or_create_by(version)
            end
          end
        end
      end

      def import_recent
        last_page = REDIS.get('nuget:page')
        last_project = REDIS.get('nuget:project')

        Catalogue.pages(last_page) do |page|
          page.packages(last_project) do |package|
            project = Project.find_or_initialize_by({name: package.name, platform: self.name.demodulize})
            if project.new_record?
              project.assign_attributes(package.to_h.except(:name))
              project.save
            else
              project.update_attributes(package.to_h.except(:name))
            end
            package.versions.each do |version|
              project.versions.find_or_create_by(version)
            end
          end
        end
      end
    end
  end
end
