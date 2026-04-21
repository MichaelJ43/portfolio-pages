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
  property summary : String
  property extra_links : Array(LinkItem) = [] of LinkItem
end

struct SiteRoot
  include YAML::Serializable
  property site : SiteMeta
  property repos : Array(RepoItem)
end

struct PageView
  getter base_path : String
  getter page_title : String
  getter intro : String
  getter links : Array(LinkItem)
  getter repos : Array(RepoItem)

  def initialize(@base_path : String, root : SiteRoot)
    @page_title = root.site.title
    @intro = root.site.intro
    @links = root.site.links
    @repos = root.repos
  end

  ECR.def_to_s "#{__DIR__}/../templates/index.ecr"
end

module Sitegen
  extend self

  def normalize_base_path(raw : String?) : String
    r = raw
    if r.nil? || r.empty?
      return "/"
    end
    r.ends_with?("/") ? r : "#{r}/"
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

  def run(content_file : String, dist_dir : String, public_dir : String)
    base = normalize_base_path(ENV["VITE_BASE_PATH"]?)
    root = load_root(content_file)
    FileUtils.mkdir_p(dist_dir)
    view = PageView.new(base, root)
    File.write(File.join(dist_dir, "index.html"), view.to_s)
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
