require "yaml"
require "ecr"
require "html"
require "json"
require "file_utils"

struct LinkItem
  include YAML::Serializable
  property label : String
  property url : String

  def initialize(@label : String, @url : String)
  end
end

struct SiteMeta
  include YAML::Serializable
  property title : String
  property subtitle : String? = nil
  property intro : String
  property links : Array(LinkItem) = [] of LinkItem
end

struct RepoBadge
  include YAML::Serializable
  property src : String
  property href : String? = nil
  property alt : String = "Release"
end

struct RepoItem
  include YAML::Serializable
  property slug : String
  property title : String
  property repo : String
  property url : String
  # When set, the card title links here (live app); otherwise title links to `url` with a "(Github)" suffix.
  property live_url : String? = nil
  property badge : RepoBadge? = nil
  # Languages in the repo, most-used first (four shown on the site).
  property languages : Array(String) = [] of String
  property skills : Array(String) = [] of String
  property summary : String
  property extra_links : Array(LinkItem) = [] of LinkItem

  def primary_url : String
    lu = live_url
    lu.nil? || lu.empty? ? url : lu
  end

  def primary_title : String
    lu = live_url
    (lu.nil? || lu.empty?) ? "#{title} (Github)" : title
  end

  def github_sub_link? : Bool
    lu = live_url
    !(lu.nil? || lu.empty?)
  end
end

struct SkillGroup
  include YAML::Serializable
  property title : String
  property items : Array(String)
end

struct DescribedItem
  include YAML::Serializable
  property title : String
  property description : String
end

struct NavigationItem
  include YAML::Serializable
  property title : String
  property url : String
  property description : String
  property note : String?
end

struct CorporateProject
  include YAML::Serializable
  property company : String
  property role : String
  property period : String
  property summary : String
  property highlights : Array(String)
  property skills : Array(String) = [] of String
end

struct SiteRoot
  include YAML::Serializable
  property site : SiteMeta
  property skills : Array(SkillGroup) = [] of SkillGroup
  property workplace_skills : Array(SkillGroup) = [] of SkillGroup
  property site_technical_aspects : Array(DescribedItem) = [] of DescribedItem
  property navigation : Array(NavigationItem) = [] of NavigationItem
  property corporate_projects : Array(CorporateProject) = [] of CorporateProject
  property repos : Array(RepoItem)
end

struct PageView
  getter page_title : String
  getter subtitle : String?
  getter intro : String
  getter links : Array(LinkItem)
  getter skills : Array(SkillGroup)
  getter workplace_skills : Array(SkillGroup)
  getter site_technical_aspects : Array(DescribedItem)
  getter repos : Array(RepoItem)

  def initialize(root : SiteRoot)
    @page_title = root.site.title
    @subtitle = root.site.subtitle
    @intro = root.site.intro
    @links = Sitegen.site_links_with_optional_contact(root.site.links)
    @skills = root.skills
    @workplace_skills = root.workplace_skills
    @site_technical_aspects = root.site_technical_aspects
    @repos = root.repos
  end

  ECR.def_to_s "#{__DIR__}/../templates/index.ecr"
end

struct NavigationView
  getter page_title : String
  getter intro : String
  getter links : Array(LinkItem)
  getter navigation : Array(NavigationItem)

  def initialize(root : SiteRoot)
    @page_title = "Navigation — Michael"
    @intro = "A quick index of public project pages, demos, and portfolio sections."
    @links = Sitegen.site_links_with_optional_contact(root.site.links)
    @navigation = root.navigation
  end

  ECR.def_to_s "#{__DIR__}/../templates/navigation.ecr"
end

struct CorporateProjectsView
  getter page_title : String
  getter intro : String
  getter links : Array(LinkItem)
  getter corporate_projects : Array(CorporateProject)

  def initialize(root : SiteRoot)
    @page_title = "Corporate Projects — Michael"
    @intro = "Public summaries of enterprise DevOps, cloud, automation, and developer tooling work."
    @links = Sitegen.site_links_with_optional_contact(root.site.links)
    @corporate_projects = root.corporate_projects
  end

  ECR.def_to_s "#{__DIR__}/../templates/corporate_projects.ecr"
end

module Sitegen
  extend self

  GITHUB_ICON_PATH = "M12 2C6.477 2 2 6.488 2 12.02c0 4.426 2.865 8.18 6.839 9.505.5.094.682-.217.682-.482 0-.236-.008-.866-.013-1.7-2.782.605-3.37-1.344-3.37-1.344-.455-1.16-1.11-1.47-1.11-1.47-.909-.621.068-.608.068-.608 1.004.07 1.532 1.033 1.532 1.033.893 1.53 2.341 1.087 2.91.832.091-.649.35-1.088.636-1.338-2.22-.252-4.555-1.113-4.555-4.954 0-1.093.39-1.987 1.029-2.688-.103-.253-.446-1.272.098-2.651 0 0 .84-.269 2.75 1.026A9.556 9.556 0 0 1 12 6.844c.85.004 1.705.115 2.504.337 1.909-1.295 2.748-1.026 2.748-1.026.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.85-2.339 4.7-4.566 4.947.359.31.678.92.678 1.855 0 1.338-.012 2.419-.012 2.748 0 .268.18.58.688.481A10.021 10.021 0 0 0 22 12.02C22 6.488 17.522 2 12 2Z"
  LINKEDIN_ICON_PATH = "M20.447 20.452H16.89V14.87c0-1.332-.025-3.047-1.857-3.047-1.86 0-2.145 1.453-2.145 2.949v5.68H9.33V9h3.414v1.561h.049c.476-.9 1.637-1.85 3.37-1.85 3.602 0 4.266 2.37 4.266 5.455v6.286zM5.337 7.433a2.065 2.065 0 1 1 0-4.13 2.065 2.065 0 0 1 0 4.13zM7.116 20.452H3.558V9h3.558v11.452z"
  MAIL_ICON_PATH = "M3 5h18a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Zm1.5 2.2v9.6h15V7.2l-7.5 5.25L4.5 7.2Zm.93-.2 6.57 4.6L18.57 7H5.43Z"

  # Inserts profile/contact links after the GitHub profile link when set via env
  # (e.g. CI deploy). Keeps private values out of the repo.
  def site_links_with_optional_contact(site_links : Array(LinkItem)) : Array(LinkItem)
    linkedin = ENV["LINKEDIN_PROFILE"]?.try(&.strip)
    email = ENV["CONTACT_EMAIL"]?.try(&.strip)
    has_linkedin = !(linkedin.nil? || linkedin.empty?)
    has_email = !(email.nil? || email.empty?)
    return site_links.dup unless has_linkedin || has_email

    out = site_links.dup
    idx = out.index { |l| l.url.includes?("github.com") }
    insert_at = idx ? idx + 1 : out.size

    if has_linkedin
      out.insert(insert_at, LinkItem.new(label: "LinkedIn profile", url: linkedin.not_nil!))
      insert_at += 1
    end

    if has_email
      out.insert(insert_at, LinkItem.new(label: "Get in touch", url: "mailto:#{email}"))
    end

    out
  end

  def profile_links_nav(links : Array(LinkItem)) : String
    String.build do |io|
      io << %(<nav class="links m43-nav" aria-label="Profiles">)
      links.each do |link|
        escaped_url = HTML.escape(link.url)
        escaped_label = HTML.escape(link.label)
        io << %(<a class="profile-link" href="#{escaped_url}">)
        if icon = icon_path_for(link.url)
          io << %(<svg class="profile-link__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">)
          io << %(<path d="#{icon}"></path></svg>)
        end
        io << %(<span>#{escaped_label}</span></a>)
      end
      io << %(</nav>)
    end
  end

  private def icon_path_for(url : String) : String?
    normalized = url.downcase
    return GITHUB_ICON_PATH if normalized.includes?("github.com")
    return LINKEDIN_ICON_PATH if normalized.includes?("linkedin.com")
    return MAIL_ICON_PATH if normalized.starts_with?("mailto:")
    nil
  end

  def load_root(path : String) : SiteRoot
    SiteRoot.from_yaml File.read(path)
  end

  def copy_public(public_dir : String, dist_dir : String)
    return unless Dir.exists?(public_dir)
    Dir.each_child(public_dir) do |name|
      src = File.join(public_dir, name)
      dst = File.join(dist_dir, name)
      FileUtils.cp_r(src, dst)
    end
  end

  def write_page(dist_dir : String, relative_path : String, html : String)
    path = File.join(dist_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, html)
  end

  def navigation_json(root : SiteRoot) : String
    JSON.build do |json|
      json.object do
        json.field "items" do
          json.array do
            root.navigation.each do |item|
              json.object do
                json.field "title", item.title
                json.field "url", item.url
                json.field "description", item.description
                if note = item.note
                  json.field "note", note
                end
              end
            end
          end
        end
      end
    end
  end

  def run(content_file : String, dist_dir : String, public_dir : String)
    root = load_root(content_file)
    FileUtils.mkdir_p(dist_dir)
    write_page(dist_dir, "index.html", PageView.new(root).to_s)
    write_page(dist_dir, File.join("navigation", "index.html"), NavigationView.new(root).to_s)
    write_page(dist_dir, "navigation.json", navigation_json(root))
    write_page(dist_dir, File.join("corporate-projects", "index.html"), CorporateProjectsView.new(root).to_s)
    copy_public(public_dir, dist_dir)
  end
end

content = ENV.fetch("CONTENT_FILE", File.join(Dir.current, "content", "repos.yml"))
dist = ENV.fetch("DIST_DIR", File.join(Dir.current, "dist"))
public_dir = ENV.fetch("PUBLIC_DIR", File.join(Dir.current, "public"))

unless File.file?(content)
  STDERR.puts "Missing content file: #{content}"
  exit 1
end

Sitegen.run(content, dist, public_dir)
puts "Wrote #{File.join(dist, "index.html")}"
