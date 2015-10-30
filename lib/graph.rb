class Graph
  def add_project(platform, name)
    resp = post('vertices', {platform: platform, name: name})
    resp[0]['id']
  end

  def add_dependency(project_id, dependency_project_id, requirements = '>= 0')
    post('edges', {outV: project_id, inV: dependency_project_id, label: 'dependency', requirements: requirements})
  end

  def export
    resp = Typhoeus::Request.new(
      "#{url}/extract",
      method: :get,
      headers: { 'Content-Type': "application/json" }
    ).run
  end

  def query(q)
    post('gremlin', {gremlin: q})
  end

  # g.query("g.V().has('platform', 'Cargo').has('name', 'cargo').repeat(out()).until(count().is(0)).emit().path().by('name')")
  # g.query("g.V().has('platform', 'Cargo').has('name', 'cargo').repeat(out()).until(count().is(0)).emit().values('name')")

  def post(path, body_hash)
    resp = Typhoeus::Request.new(
      "#{url}/#{path}",
      method: :post,
      body: body_hash.to_json,
      headers: { 'Content-Type': "application/json" }
    ).run
    body = resp.body
    Oj.load(body)["result"]["data"]
  end

  def get(path)
    resp = Typhoeus.get "#{url}/#{path}"
    body = resp.body
    Oj.load(body)["result"]["data"]
  end

  def url
    "https://8e22d065-1a12-425e-a820-45359eba646c:f17cbedc-1e38-4674-892a-024019bc29ef@graphrestify.eu-gb.bluemix.net/graphs/d7d31a53-f445-43dc-82de-0349aa94ddf2/g83819938"
  end
end
