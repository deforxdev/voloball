class_name RoundedBox
extends RefCounted






static func make(size: Vector3, bevel: float) -> ArrayMesh:
	var h: = size * 0.5
	var c: float = min(bevel, min(h.x, min(h.y, h.z)) * 0.9)
	var ex: = h.x; var ey: = h.y; var ez: = h.z
	var ix: = ex - c; var iy: = ey - c; var iz: = ez - c

	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var signs: = [1.0, -1.0]


	_quad(st, Vector3(ex, - iy, - iz), Vector3(ex, - iy, iz), Vector3(ex, iy, iz), Vector3(ex, iy, - iz), Vector3(1, 0, 0))
	_quad(st, Vector3( - ex, - iy, - iz), Vector3( - ex, iy, - iz), Vector3( - ex, iy, iz), Vector3( - ex, - iy, iz), Vector3(-1, 0, 0))
	_quad(st, Vector3( - ix, ey, - iz), Vector3( - ix, ey, iz), Vector3(ix, ey, iz), Vector3(ix, ey, - iz), Vector3(0, 1, 0))
	_quad(st, Vector3( - ix, - ey, - iz), Vector3(ix, - ey, - iz), Vector3(ix, - ey, iz), Vector3( - ix, - ey, iz), Vector3(0, -1, 0))
	_quad(st, Vector3( - ix, - iy, ez), Vector3(ix, - iy, ez), Vector3(ix, iy, ez), Vector3( - ix, iy, ez), Vector3(0, 0, 1))
	_quad(st, Vector3( - ix, - iy, - ez), Vector3( - ix, iy, - ez), Vector3(ix, iy, - ez), Vector3(ix, - iy, - ez), Vector3(0, 0, -1))


	for sx in signs:
		for sy in signs:
			var n1: = Vector3(sx, sy, 0.0).normalized()
			_quad(st, Vector3(sx * ex, sy * iy, - iz), Vector3(sx * ex, sy * iy, iz), 
				Vector3(sx * ix, sy * ey, iz), Vector3(sx * ix, sy * ey, - iz), n1)
	for sx in signs:
		for sz in signs:
			var n2: = Vector3(sx, 0.0, sz).normalized()
			_quad(st, Vector3(sx * ex, - iy, sz * iz), Vector3(sx * ex, iy, sz * iz), 
				Vector3(sx * ix, iy, sz * ez), Vector3(sx * ix, - iy, sz * ez), n2)
	for sy in signs:
		for sz in signs:
			var n3: = Vector3(0.0, sy, sz).normalized()
			_quad(st, Vector3( - ix, sy * ey, sz * iz), Vector3(ix, sy * ey, sz * iz), 
				Vector3(ix, sy * iy, sz * ez), Vector3( - ix, sy * iy, sz * ez), n3)


	for sx in signs:
		for sy in signs:
			for sz in signs:
				var n: = Vector3(sx, sy, sz).normalized()
				_tri(st, Vector3(sx * ex, sy * iy, sz * iz), Vector3(sx * ix, sy * ey, sz * iz), 
					Vector3(sx * ix, sy * iy, sz * ez), n)

	return st.commit()

static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, n: Vector3) -> void :
	st.set_normal(n);st.add_vertex(a)
	st.set_normal(n);st.add_vertex(b)
	st.set_normal(n);st.add_vertex(c)

static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, n: Vector3) -> void :
	_tri(st, a, b, c, n)
	_tri(st, a, c, d, n)
