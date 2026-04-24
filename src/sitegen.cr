require "yaml"
require "ecr"
require "html"
require "file_utils"

struct LinkItem
  include YAML::Serializable
  property label : String
  property url : String
end

struct SiteMeta
  include YAML::Serializable
  property title : String
  property intro : String
  property links : Array(LinkItem) = [] of LinkItem
end

struct RepoItem
  include YAML::Serializable
  property slug : String
  property title : String
  property repo : String
  property url : String
  property language : String?
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
    @links = root.site.links
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
    @links = root.site.links
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
    @links = root.site.links
    @corporate_projects = root.corporate_projects
  end

  ECR.def_to_s "#{__DIR__}/../templates/corporate_projects.ecr"
end

module Sitegen
  extend self

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

  def run(content_file : String, dist_dir : String, public_dir : String)
    root = load_root(content_file)
    FileUtils.mkdir_p(dist_dir)
    write_page(dist_dir, "index.html", PageView.new(root).to_s)
    write_page(dist_dir, File.join("navigation", "index.html"), NavigationView.new(root).to_s)
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
