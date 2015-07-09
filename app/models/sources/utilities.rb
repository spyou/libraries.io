module Sources
  module Utilities
    def self.included cls
      cls.extend self
    end

    def get(url, options = {})
      Oj.load(get_raw(url, options))
    end

    def get_raw(url, options = {})
      Typhoeus.get(url, options).body
    end

    def repo_fallback(repo, homepage)
      repo = '' if repo.nil?
      homepage = '' if homepage.nil?
      repo_gh = GithubRepository.extract_full_name(repo)
      homepage_gh = GithubRepository.extract_full_name(homepage)
      if repo_gh.present?
        return "https://github.com/#{repo_gh}"
      elsif homepage_gh.present?
        return "https://github.com/#{homepage_gh}"
      else
        repo
      end
    end
  end
end
