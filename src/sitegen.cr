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
  property intro : String
  property links : Array(LinkItem) = [] of LinkItem
end

struct LanguageShare
  include YAML::Serializable
  property name : String
  property pct : Int32
end

struct RepoItem
  include YAML::Serializable
  property slug : String
  property title : String
  property repo : String
  property url : String
  property language : String?
  property language_shares : Array(LanguageShare) = [] of LanguageShare
  property skills : Array(String) = [] of String
  property summary : String
  property extra_links : Array(LinkItem) = [] of LinkItem
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
  property site_technical_aspects : Array(DescribedItem) = [] of DescribedItem
  property navigation : Array(NavigationItem) = [] of NavigationItem
  property corporate_projects : Array(CorporateProject) = [] of CorporateProject
  property repos : Array(RepoItem)
end

struct PageView
  getter page_title : String
  getter intro : String
  getter links : Array(LinkItem)
  getter skills : Array(SkillGroup)
  getter site_technical_aspects : Array(DescribedItem)
  getter repos : Array(RepoItem)

  def initialize(root : SiteRoot)
    @page_title = root.site.title
    @intro = root.site.intro
    @links = Sitegen.site_links_with_optional_contact(root.site.links)
    @skills = root.skills
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

  # Inserts a mailto link after the GitHub profile link when CONTACT_EMAIL is set
  # (e.g. CI deploy). Keeps the address out of the repo; Cloudflare can obfuscate on the wire.
  def site_links_with_optional_contact(site_links : Array(LinkItem)) : Array(LinkItem)
    email = ENV["CONTACT_EMAIL"]?.try(&.strip)
    return site_links.dup if email.nil? || email.empty?

    out = site_links.dup
    contact = LinkItem.new(label: "Get in touch", url: "mailto:#{email}")
    idx = out.index { |l| l.url.includes?("github.com") }
    if idx
      out.insert(idx + 1, contact)
    else
      out << contact
    end
    out
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
