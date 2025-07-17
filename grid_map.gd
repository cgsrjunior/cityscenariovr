extends MeshInstance3D

func _ready():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(10, 10)
	plane_mesh.subdivide_depth = 20
	plane_mesh.subdivide_width = 20
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_mesh = surface_tool.commit()
	var data = array_mesh.surface_get_arrays(0)
	var verts = data[Mesh.ARRAY_VERTEX] as PackedVector3Array
	
	# Modifica os vértices para criar o declive suave
	for i in verts.size():
		var v = verts[i]
		# Cria um vale no meio do plano
		if v.x > -3 and v.x < 3 and v.z > -3 and v.z < 3:
			verts[i].y = -0.5 * exp(-(v.x*v.x + v.z*v.z)/8.0)
	
	data[Mesh.ARRAY_VERTEX] = verts
	array_mesh.clear_surfaces()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	self.mesh = array_mesh
	
	# Adiciona colisão automaticamente
	self.create_trimesh_collision()
