class_name QrCode
extends RefCounted














enum {L, M, Q, H}

const MAX_VERSION: = 40
const MAX_READ_PX: = 2000
const _ECL_BITS: = [1, 0, 3, 2]
const _ECC_PER_BLOCK: = [
	[-1, 7, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30, 22, 24, 28, 30, 28, 28, 28, 28, 30, 30, 26, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30], 
	[-1, 10, 16, 26, 18, 24, 16, 18, 22, 22, 26, 30, 22, 22, 24, 24, 28, 28, 26, 26, 26, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28], 
	[-1, 13, 22, 18, 26, 18, 24, 18, 22, 20, 24, 28, 26, 24, 20, 30, 24, 28, 28, 26, 30, 28, 30, 30, 30, 30, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30], 
	[-1, 17, 28, 22, 16, 22, 28, 26, 26, 24, 28, 24, 28, 22, 24, 24, 30, 28, 28, 26, 28, 30, 24, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30]]
const _BLOCKS: = [
	[-1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 4, 4, 4, 6, 6, 6, 6, 7, 8, 8, 9, 9, 10, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 24, 25], 
	[-1, 1, 1, 1, 2, 2, 4, 4, 4, 5, 5, 5, 8, 9, 9, 10, 10, 11, 13, 14, 16, 17, 17, 18, 20, 21, 23, 25, 26, 28, 29, 31, 33, 35, 37, 38, 40, 43, 45, 47, 49], 
	[-1, 1, 1, 2, 2, 4, 4, 6, 6, 8, 8, 8, 10, 12, 16, 12, 17, 16, 18, 21, 20, 23, 23, 25, 27, 29, 34, 34, 35, 38, 40, 43, 45, 48, 51, 53, 56, 59, 62, 65, 68], 
	[-1, 1, 1, 2, 4, 4, 4, 5, 6, 8, 8, 11, 11, 16, 16, 18, 16, 19, 21, 25, 25, 25, 34, 30, 32, 35, 37, 40, 42, 45, 48, 51, 54, 57, 60, 63, 66, 70, 74, 77, 81]]






static func make(data: PackedByteArray, min_ecl: = M, mask: = -1, boost: = true) -> Array:
	_gf()
	var ver: = 0
	for v in range(1, MAX_VERSION + 1):
		if _fits(data.size(), v, min_ecl):
			ver = v
			break
	if ver == 0:
		return []
	var ecl: = min_ecl
	for e in [M, Q, H]:
		if boost and e > ecl and _fits(data.size(), ver, e):
			ecl = e
	var bits: Array[int] = []
	_put_bits(bits, 4, 4)
	_put_bits(bits, data.size(), _count_bits(ver))
	for b in data:
		_put_bits(bits, b, 8)
	var cap: = _data_codewords(ver, ecl) * 8
	_put_bits(bits, 0, mini(4, cap - bits.size()))
	_put_bits(bits, 0, (8 - bits.size() % 8) % 8)
	var cw: = PackedByteArray()
	for i in range(0, bits.size(), 8):
		var byte: = 0
		for k in 8:
			byte = (byte << 1) | bits[i + k]
		cw.append(byte)
	var pad: = 236
	while cw.size() < cap / 8:
		cw.append(pad)
		pad ^= 236 ^ 17
	var grid: = _Grid.new(ver)
	grid.draw_function_patterns()
	grid.draw_codewords(_add_ecc(cw, ver, ecl))
	var best: = mask
	if best < 0:
		var low: = 1 << 62
		for m in 8:
			grid.apply_mask(m)
			grid.draw_format(_ECL_BITS[ecl], m)
			var p: = grid.penalty()
			if p < low:
				low = p
				best = m
			grid.apply_mask(m)
	grid.apply_mask(best)
	grid.draw_format(_ECL_BITS[ecl], best)
	return grid.rows()


static func image(grid: Array, px: int, quiet: int, dark: = Color.BLACK, light: = Color.WHITE) -> Image:
	var n: = grid.size()
	var side: = (n + quiet * 2) * px
	var img: = Image.create(side, side, false, Image.FORMAT_RGBA8)
	img.fill(light)
	for y in n:
		var row: PackedByteArray = grid[y]
		for x in n:
			if row[x] == 1:
				img.fill_rect(Rect2i((x + quiet) * px, (y + quiet) * px, px, px), dark)
	return img

static func _fits(n: int, ver: int, ecl: int) -> bool:
	return 4 + _count_bits(ver) + n * 8 <= _data_codewords(ver, ecl) * 8

static func _count_bits(ver: int) -> int:
	return 8 if ver <= 9 else 16

static func _raw_modules(ver: int) -> int:
	var r: = (16 * ver + 128) * ver + 64
	if ver >= 2:
		var n: = ver / 7 + 2
		r -= (25 * n - 10) * n - 55
		if ver >= 7:
			r -= 36
	return r

static func _data_codewords(ver: int, ecl: int) -> int:
	return _raw_modules(ver) / 8 - _ECC_PER_BLOCK[ecl][ver] * _BLOCKS[ecl][ver]

static func _put_bits(bits: Array[int], v: int, n: int) -> void :
	for i in range(n - 1, -1, -1):
		bits.append((v >> i) & 1)


static func _add_ecc(data: PackedByteArray, ver: int, ecl: int) -> PackedByteArray:
	var nb: int = _BLOCKS[ecl][ver]
	var ecc_len: int = _ECC_PER_BLOCK[ecl][ver]
	var raw: = _raw_modules(ver) / 8
	var n_short: = nb - raw % nb
	var short_len: = raw / nb
	var div: = _rs_divisor(ecc_len)
	var blocks: Array = []
	var k: = 0
	for i in nb:
		var dat_len: = short_len - ecc_len + (0 if i < n_short else 1)
		var dat: = data.slice(k, k + dat_len)
		k += dat_len
		var blk: = dat.duplicate()
		if i < n_short:
			blk.append(0)
		blk.append_array(_rs_remainder(dat, div))
		blocks.append(blk)
	var out: = PackedByteArray()
	for i in (blocks[0] as PackedByteArray).size():
		for j in nb:
			if i != short_len - ecc_len or j >= n_short:
				out.append(blocks[j][i])
	return out




static func read(img: Image) -> PackedByteArray:
	if img == null or img.is_empty() or img.get_width() < 21 or img.get_height() < 21:
		return PackedByteArray()
	_gf()
	var src: = img.duplicate() as Image
	if src.is_compressed() and src.decompress() != OK:
		return PackedByteArray()

	src.convert(Image.FORMAT_RGBA8)
	var flat: = Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	flat.fill(Color.WHITE)
	flat.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i.ZERO)
	flat.convert(Image.FORMAT_L8)
	while maxi(flat.get_width(), flat.get_height()) > MAX_READ_PX:
		flat.resize(maxi(flat.get_width() / 2, 1), maxi(flat.get_height() / 2, 1), Image.INTERPOLATE_BILINEAR)



	for how in [_Reader.WIDE, _Reader.WHOLE, _Reader.TIGHT]:
		var out: = _Reader.new(flat, how).run()
		if not out.is_empty():
			return out
	return PackedByteArray()



static var _exp: = PackedInt32Array()
static var _log: = PackedInt32Array()

static func _gf() -> void :
	if not _exp.is_empty():
		return
	_exp.resize(512)
	_log.resize(256)
	var x: = 1
	for i in 255:
		_exp[i] = x
		_log[x] = i
		x <<= 1
		if x & 256:
			x ^= 285
	for i in range(255, 512):
		_exp[i] = _exp[i - 255]

static func _mul(a: int, b: int) -> int:
	return 0 if a == 0 or b == 0 else _exp[_log[a] + _log[b]]

static func _div(a: int, b: int) -> int:
	return 0 if a == 0 else _exp[(_log[a] + 255 - _log[b]) % 255]

static func _pow(a: int, e: int) -> int:
	if e == 0:
		return 1
	return 0 if a == 0 else _exp[(_log[a] * e) % 255]


static func _rs_divisor(degree: int) -> PackedByteArray:
	var r: = PackedByteArray()
	r.resize(degree)
	r[degree - 1] = 1
	var root: = 1
	for _i in degree:
		for j in degree:
			r[j] = _mul(r[j], root)
			if j + 1 < degree:
				r[j] ^= r[j + 1]
		root = _mul(root, 2)
	return r

static func _rs_remainder(data: PackedByteArray, div: PackedByteArray) -> PackedByteArray:
	var r: = PackedByteArray()
	r.resize(div.size())
	for b in data:
		var factor: = b ^ r[0]
		r.remove_at(0)
		r.append(0)
		for i in div.size():
			r[i] ^= _mul(div[i], factor)
	return r




static func _rs_fix(src: PackedByteArray, ecc_len: int) -> PackedByteArray:
	var block: = src.duplicate()
	var n: = block.size()
	var synd: = _syndromes(block, ecc_len)
	if synd.is_empty():
		return block
	var c: Array[int] = [1]
	var b_poly: Array[int] = [1]
	var deg: = 0
	var shift: = 1
	var b: = 1
	for k in ecc_len:
		var d: = synd[k]
		for i in range(1, deg + 1):
			if i < c.size():
				d ^= _mul(c[i], synd[k - i])
		if d == 0:
			shift += 1
			continue
		var coef: = _div(d, b)
		var t: = c.duplicate()
		while c.size() < b_poly.size() + shift:
			c.append(0)
		for i in b_poly.size():
			c[i + shift] ^= _mul(coef, b_poly[i])
		if 2 * deg <= k:
			deg = k + 1 - deg
			b_poly = t
			b = d
			shift = 1
		else:
			shift += 1
	if deg * 2 > ecc_len:
		return PackedByteArray()
	var where: Array[int] = []
	for p in n:
		var xinv: = _exp[(255 - p) % 255]
		var v: = 0
		for i in range(c.size() - 1, -1, -1):
			v = _mul(v, xinv) ^ c[i]
		if v == 0:
			where.append(p)
	if where.size() != deg:
		return PackedByteArray()
	var omega: = PackedInt32Array()
	omega.resize(ecc_len)
	for i in ecc_len:
		var s: = 0
		for j in mini(i, c.size() - 1) + 1:
			s ^= _mul(c[j], synd[i - j])
		omega[i] = s
	for p in where:
		var x: = _exp[p]
		var xinv: = _exp[(255 - p) % 255]
		var om: = 0
		for i in range(ecc_len - 1, -1, -1):
			om = _mul(om, xinv) ^ omega[i]
		var dp: = 0
		for i in range(1, c.size(), 2):
			dp ^= _mul(c[i], _pow(xinv, i - 1))
		if dp == 0:
			return PackedByteArray()
		block[n - 1 - p] ^= _mul(x, _div(om, dp))
	return block if _syndromes(block, ecc_len).is_empty() else PackedByteArray()


static func _syndromes(block: PackedByteArray, ecc_len: int) -> PackedInt32Array:
	var synd: = PackedInt32Array()
	synd.resize(ecc_len)
	var any: = false
	for j in ecc_len:
		var a: = _exp[j]
		var s: = 0
		for v in block:
			s = _mul(s, a) ^ v
		synd[j] = s
		any = any or s != 0
	return synd if any else PackedInt32Array()


static func _format_bits(ecl_bits: int, mask: int) -> int:
	var data: = (ecl_bits << 3) | mask
	var rem: = data
	for _i in 10:
		rem = (rem << 1) ^ ((rem >> 9) * 1335)
	return ((data << 10) | (rem & 1023)) ^ 21522

static func _version_bits(ver: int) -> int:
	var rem: = ver
	for _i in 12:
		rem = (rem << 1) ^ ((rem >> 11) * 7973)
	return (ver << 12) | (rem & 4095)

static func _mask_on(m: int, x: int, y: int) -> bool:
	match m:
		0: return (x + y) % 2 == 0
		1: return y % 2 == 0
		2: return x % 3 == 0
		3: return (x + y) % 3 == 0
		4: return (x / 3 + y / 2) % 2 == 0
		5: return x * y % 2 + x * y % 3 == 0
		6: return (x * y % 2 + x * y % 3) % 2 == 0
	return ((x + y) % 2 + x * y % 3) % 2 == 0

static func _popcount(v: int) -> int:
	var n: = 0
	while v != 0:
		n += v & 1
		v >>= 1
	return n



class _Grid:
	var ver: int
	var size: int
	var mods: = PackedByteArray()
	var fn: = PackedByteArray()

	func _init(v: int) -> void :
		ver = v
		size = 17 + 4 * v
		mods.resize(size * size)
		fn.resize(size * size)

	func put(x: int, y: int, dark: bool) -> void :
		mods[y * size + x] = 1 if dark else 0
		fn[y * size + x] = 1

	func draw_function_patterns() -> void :
		for i in size:
			put(6, i, i % 2 == 0)
			put(i, 6, i % 2 == 0)
		_finder(3, 3)
		_finder(size - 4, 3)
		_finder(3, size - 4)
		var pos: = alignment_positions()
		var n: = pos.size()
		for i in n:
			for j in n:
				if (i == 0 and j == 0) or (i == 0 and j == n - 1) or (i == n - 1 and j == 0):
					continue
				for dy in range(-2, 3):
					for dx in range(-2, 3):
						put(pos[i] + dx, pos[j] + dy, maxi(absi(dx), absi(dy)) != 1)
		draw_format(0, 0)
		if ver >= 7:
			var bits: = _version_bits_of(ver)
			for i in 18:
				var on: = ((bits >> i) & 1) == 1
				put(size - 11 + i % 3, i / 3, on)
				put(i / 3, size - 11 + i % 3, on)

	func _finder(cx: int, cy: int) -> void :
		for dy in range(-4, 5):
			for dx in range(-4, 5):
				var x: = cx + dx
				var y: = cy + dy
				if x >= 0 and x < size and y >= 0 and y < size:
					var d: = maxi(absi(dx), absi(dy))
					put(x, y, d != 2 and d != 4)

	func alignment_positions() -> Array:
		if ver == 1:
			return []
		var n: = ver / 7 + 2
		var step: = 26 if ver == 32 else (ver * 4 + n * 2 + 1) / (n * 2 - 2) * 2
		var out: = [6]
		var tail: Array = []
		for i in n - 1:
			tail.push_front(size - 7 - i * step)
		out.append_array(tail)
		return out

	func draw_format(ecl_bits: int, mask: int) -> void :
		var data: = (ecl_bits << 3) | mask
		var rem: = data
		for _i in 10:
			rem = (rem << 1) ^ ((rem >> 9) * 1335)
		var bits: = ((data << 10) | (rem & 1023)) ^ 21522
		for i in 6:
			put(8, i, _bit(bits, i))
		put(8, 7, _bit(bits, 6))
		put(8, 8, _bit(bits, 7))
		put(7, 8, _bit(bits, 8))
		for i in range(9, 15):
			put(14 - i, 8, _bit(bits, i))
		for i in 8:
			put(size - 1 - i, 8, _bit(bits, i))
		for i in range(8, 15):
			put(8, size - 15 + i, _bit(bits, i))
		put(8, size - 8, true)

	func _version_bits_of(v: int) -> int:
		var rem: = v
		for _i in 12:
			rem = (rem << 1) ^ ((rem >> 11) * 7973)
		return (v << 12) | (rem & 4095)

	static func _bit(v: int, i: int) -> bool:
		return ((v >> i) & 1) == 1



	func draw_codewords(data: PackedByteArray) -> void :
		var i: = 0
		var right: = size - 1
		while right >= 1:
			if right == 6:
				right = 5
			for vert in size:
				for j in 2:
					var x: = right - j
					var up: = ((right + 1) & 2) == 0
					var y: = size - 1 - vert if up else vert
					if fn[y * size + x] == 0 and i < data.size() * 8:
						mods[y * size + x] = (data[i >> 3] >> (7 - (i & 7))) & 1
						i += 1
			right -= 2


	func read_codewords() -> PackedByteArray:
		var out: = PackedByteArray()
		out.resize(_raw_bytes())
		var i: = 0
		var right: = size - 1
		while right >= 1:
			if right == 6:
				right = 5
			for vert in size:
				for j in 2:
					var x: = right - j
					var up: = ((right + 1) & 2) == 0
					var y: = size - 1 - vert if up else vert
					if fn[y * size + x] == 0 and i < out.size() * 8:
						if mods[y * size + x] == 1:
							out[i >> 3] |= 128 >> (i & 7)
						i += 1
			right -= 2
		return out

	func _raw_bytes() -> int:
		var r: = (16 * ver + 128) * ver + 64
		if ver >= 2:
			var n: = ver / 7 + 2
			r -= (25 * n - 10) * n - 55
			if ver >= 7:
				r -= 36
		return r / 8

	func apply_mask(m: int) -> void :
		for y in size:
			for x in size:
				if fn[y * size + x] == 0 and _mask(m, x, y):
					mods[y * size + x] ^= 1

	static func _mask(m: int, x: int, y: int) -> bool:
		match m:
			0: return (x + y) % 2 == 0
			1: return y % 2 == 0
			2: return x % 3 == 0
			3: return (x + y) % 3 == 0
			4: return (x / 3 + y / 2) % 2 == 0
			5: return x * y % 2 + x * y % 3 == 0
			6: return (x * y % 2 + x * y % 3) % 2 == 0
		return ((x + y) % 2 + x * y % 3) % 2 == 0


	func penalty() -> int:
		var result: = 0
		for y in size:
			result += _line_penalty( func(i): return mods[y * size + i])
		for x in size:
			result += _line_penalty( func(i): return mods[i * size + x])
		for y in size - 1:
			for x in size - 1:
				var c: = mods[y * size + x]
				if c == mods[y * size + x + 1] and c == mods[(y + 1) * size + x]\
				and c == mods[(y + 1) * size + x + 1]:
					result += 3
		var dark: = 0
		for v in mods:
			dark += v
		var total: = size * size
		var k: = int(ceil(absf(dark * 20.0 - total * 10.0) / total)) - 1
		return result + maxi(k, 0) * 10

	func _line_penalty(at: Callable) -> int:
		var result: = 0
		var run_color: = 0
		var run: = 0
		var hist: = [0, 0, 0, 0, 0, 0, 0]
		for i in size:
			var c: int = at.call(i)
			if c == run_color:
				run += 1
				if run == 5:
					result += 3
				elif run > 5:
					result += 1
			else:
				_hist_add(run, hist)
				if run_color == 0:
					result += _finder_like(hist) * 40
				run_color = c
				run = 1
		if run_color == 1:
			_hist_add(run, hist)
			run = 0
		run += size
		_hist_add(run, hist)
		return result + _finder_like(hist) * 40

	func _hist_add(run: int, hist: Array) -> void :
		if hist[0] == 0:
			run += size
		for i in range(6, 0, -1):
			hist[i] = hist[i - 1]
		hist[0] = run

	func _finder_like(h: Array) -> int:
		var n: int = h[1]
		var core: bool = n > 0 and h[2] == n and h[3] == n * 3 and h[4] == n and h[5] == n
		return (1 if core and h[0] >= n * 4 and h[6] >= n else 0)\
		+ (1 if core and h[6] >= n * 4 and h[0] >= n else 0)

	func rows() -> Array:
		var out: Array = []
		for y in size:
			out.append(mods.slice(y * size, (y + 1) * size))
		return out



class _Reader:
	enum {WIDE, WHOLE, TIGHT}
	const OFFSET: = 12
	var w: int
	var h: int
	var gray: = PackedByteArray()
	var mean: = PackedByteArray()
	var found: Array = []

	func _init(img: Image, how: int) -> void :
		w = img.get_width()
		h = img.get_height()
		gray = img.get_data()
		if how == WHOLE:
			mean.resize(w * h)
			mean.fill(clampi(_whole_cut(img) + OFFSET, 0, 255))
			return



		var m: = img.duplicate() as Image
		var halvings: = 0
		while (TIGHT == how and halvings < 4) or (how == WIDE and maxi(m.get_width(), m.get_height()) > 24):
			m.resize(maxi(m.get_width() / 2, 1), maxi(m.get_height() / 2, 1), Image.INTERPOLATE_BILINEAR)
			halvings += 1
		m.resize(w, h, Image.INTERPOLATE_BILINEAR)
		mean = m.get_data()


	static func _whole_cut(img: Image) -> int:
		var small: = img.duplicate() as Image
		while maxi(small.get_width(), small.get_height()) > 400:
			small.resize(maxi(small.get_width() / 2, 1), maxi(small.get_height() / 2, 1), Image.INTERPOLATE_BILINEAR)
		var px: = small.get_data()
		var v: = PackedFloat32Array()
		v.resize(px.size())
		for i in px.size():
			v[i] = px[i]
		return int(_otsu(v))

	func dark(x: int, y: int) -> bool:
		var i: = y * w + x
		return gray[i] + OFFSET < mean[i]

	func run() -> PackedByteArray:
		var step: = 1 if h < 700 else 2
		for y in range(0, h, step):
			_scan_row(y)
		for tri in _triples():
			var out: = _decode(tri)
			if not out.is_empty():
				return out
		return PackedByteArray()


	func _scan_row(y: int) -> void :
		var c: = [0, 0, 0, 0, 0]
		var state: = 0
		var base: = y * w
		for x in w:
			if gray[base + x] + OFFSET < mean[base + x]:
				if state & 1 == 1:
					state += 1
				c[state] += 1
			elif state & 1 == 0:
				if state == 4:
					if _cross(c):
						_found_at(c, y, x)
					c = [c[2], c[3], c[4], 1, 0]
					state = 3
				else:
					state += 1
					c[state] += 1
			else:
				c[state] += 1
		if state == 4 and _cross(c):
			_found_at(c, y, w)

	static func _cross(c: Array) -> bool:
		var total: int = c[0] + c[1] + c[2] + c[3] + c[4]
		if total < 7:
			return false
		var m: = total / 7.0
		var v: = m / 2.0
		return absf(m - c[0]) < v and absf(m - c[1]) < v and absf(3.0 * m - c[2]) < 3.0 * v\
		and absf(m - c[3]) < v and absf(m - c[4]) < v

	func _found_at(c: Array, y: int, end_x: int) -> void :
		var total: int = c[0] + c[1] + c[2] + c[3] + c[4]
		var cx: float = end_x - c[4] - c[3] - c[2] / 2.0
		var cy: = _cross_check(int(cx), y, c[2], total, true)
		if cy < 0.0:
			return
		cx = _cross_check(int(cx), int(cy), c[2], total, false)
		if cx < 0.0:
			return
		var module: = total / 7.0
		for f in found:
			if absf(f[0] - cx) <= module * 1.5 and absf(f[1] - cy) <= module * 1.5\
			and absf(f[2] - module) <= maxf(1.0, f[2] * 0.5):
				var n: int = f[3]
				f[0] = (f[0] * n + cx) / (n + 1)
				f[1] = (f[1] * n + cy) / (n + 1)
				f[2] = (f[2] * n + module) / (n + 1)
				f[3] = n + 1
				return
		found.append([cx, cy, module, 1])



	func _cross_check(cx: int, cy: int, max_count: int, total_seen: int, vertical: bool) -> float:
		var lim: = h if vertical else w
		var start: = cy if vertical else cx
		var c: = [0, 0, 0, 0, 0]
		var i: = start
		while i >= 0 and _at(cx, cy, i, vertical):
			c[2] += 1
			i -= 1
		if i < 0:
			return -1.0
		while i >= 0 and not _at(cx, cy, i, vertical) and c[1] <= max_count:
			c[1] += 1
			i -= 1
		if i < 0 or c[1] > max_count:
			return -1.0
		while i >= 0 and _at(cx, cy, i, vertical) and c[0] <= max_count:
			c[0] += 1
			i -= 1
		if c[0] > max_count:
			return -1.0
		i = start + 1
		while i < lim and _at(cx, cy, i, vertical):
			c[2] += 1
			i += 1
		if i == lim:
			return -1.0
		while i < lim and not _at(cx, cy, i, vertical) and c[3] < max_count:
			c[3] += 1
			i += 1
		if i == lim or c[3] >= max_count:
			return -1.0
		while i < lim and _at(cx, cy, i, vertical) and c[4] < max_count:
			c[4] += 1
			i += 1
		if c[4] >= max_count:
			return -1.0
		var total: int = c[0] + c[1] + c[2] + c[3] + c[4]
		if 5 * absi(total - total_seen) >= 2 * total_seen or not _cross(c):
			return -1.0
		return i - c[4] - c[3] - c[2] / 2.0

	func _at(cx: int, cy: int, i: int, vertical: bool) -> bool:
		return dark(cx, i) if vertical else dark(i, cy)



	func _triples() -> Array:
		var cands: = found.filter( func(f): return f[3] >= 2)
		if cands.size() < 3:
			cands = found.duplicate()
		cands.sort_custom( func(a, b): return a[3] > b[3])
		cands = cands.slice(0, 12)
		var out: Array = []
		for i in cands.size():
			for j in range(i + 1, cands.size()):
				for k in range(j + 1, cands.size()):
					var t: = _triple(cands[i], cands[j], cands[k])
					if not t.is_empty():
						out.append(t)
		out.sort_custom( func(a, b): return a[0] < b[0])
		return out.slice(0, 6)

	func _triple(a: Array, b: Array, c: Array) -> Array:
		var mods: Array = [a[2], b[2], c[2]]
		if mods.max() > mods.min() * 1.4:
			return []
		var pa: = Vector2(a[0], a[1])
		var pb: = Vector2(b[0], b[1])
		var pc: = Vector2(c[0], c[1])
		var dab: = pa.distance_to(pb)
		var dac: = pa.distance_to(pc)
		var dbc: = pb.distance_to(pc)
		var corner: = pa
		var p1: = pb
		var p2: = pc
		if dab >= dac and dab >= dbc:
			corner = pc
			p1 = pa
			p2 = pb
		elif dac >= dab and dac >= dbc:
			corner = pb
			p1 = pa
			p2 = pc
		var l1: = corner.distance_to(p1)
		var l2: = corner.distance_to(p2)
		var hyp: = p1.distance_to(p2)
		var legs: = absf(l1 - l2) / maxf(l1, l2)
		var right: = absf(hyp * hyp - (l1 * l1 + l2 * l2)) / (l1 * l1 + l2 * l2)
		var module: float = (a[2] + b[2] + c[2]) / 3.0
		if legs > 0.2 or right > 0.15 or (l1 + l2) * 0.5 / module < 13.0:
			return []
		if (p1 - corner).cross(p2 - corner) < 0.0:
			var s: = p1
			p1 = p2
			p2 = s
		return [legs + right, corner, p1, p2, module]

	func _decode(tri: Array) -> PackedByteArray:
		var tl: Vector2 = tri[1]
		var tr: Vector2 = tri[2]
		var bl: Vector2 = tri[3]
		var module: float = tri[4]
		var est: = int(round((tl.distance_to(tr) + tl.distance_to(bl)) * 0.5 / module)) + 7
		var dims: Array[int] = []
		for d in [est, est - 1, est + 1, est - 2, est + 2, est - 4, est + 4]:
			if d % 4 == 1 and d >= 21 and d <= 177 and not dims.has(d):
				dims.append(d)
		for d in dims:
			var out: = _decode_dim(tl, tr, bl, d, true)
			if not out.is_empty():
				return out
		return PackedByteArray()

	func _decode_dim(tl: Vector2, tr: Vector2, bl: Vector2, dim: int, trust_version: bool) -> PackedByteArray:
		var ex: = (tr - tl) / (dim - 7)
		var ey: = (bl - tl) / (dim - 7)
		var origin: = tl - ex * 3.5 - ey * 3.5
		var samples: = PackedFloat32Array()
		samples.resize(dim * dim)
		for r in dim:
			for c in dim:
				samples[r * dim + c] = _sample(origin + ex * (c + 0.5) + ey * (r + 0.5), ex, ey)
		var thr: = _otsu(samples)
		var bits: = PackedByteArray()
		bits.resize(dim * dim)
		for i in samples.size():
			bits[i] = 1 if samples[i] < thr else 0
		var ver: = (dim - 17) / 4

		if ver >= 7 and trust_version:
			var said: = _read_version(bits, dim)
			if said > 0 and said != ver:
				return _decode_dim(tl, tr, bl, 17 + 4 * said, false)
		var fmt: = _read_format(bits, dim)
		if fmt.is_empty():
			return PackedByteArray()
		var g: = _Grid.new(ver)
		g.draw_function_patterns()
		var fn: = g.fn
		var plain: = PackedByteArray()
		plain.resize(dim * dim)
		for y in dim:
			for x in dim:
				var i: = y * dim + x
				plain[i] = bits[i] ^ (1 if fn[i] == 0 and _Grid._mask(fmt[1], x, y) else 0)
		g.mods = plain
		return _unpack(g.read_codewords(), ver, fmt[0])


	func _sample(p: Vector2, ex: Vector2, ey: Vector2) -> float:
		var s: = 0.0
		for o in [Vector2.ZERO, ex * 0.22, ex * -0.22, ey * 0.22, ey * -0.22]:
			var q: Vector2 = p + o
			var x: = int(q.x)
			var y: = int(q.y)
			s += gray[y * w + x] if x >= 0 and y >= 0 and x < w and y < h else 255
		return s / 5.0

	static func _otsu(v: PackedFloat32Array) -> float:
		var hist: = PackedInt32Array()
		hist.resize(256)
		for s in v:
			hist[clampi(int(s), 0, 255)] += 1
		var total: = v.size()
		var sum: = 0.0
		for i in 256:
			sum += i * hist[i]
		var sum_b: = 0.0
		var w_b: = 0
		var best: = 0.0
		var thr: = 128.0
		for i in 256:
			w_b += hist[i]
			if w_b == 0:
				continue
			var w_f: = total - w_b
			if w_f == 0:
				break
			sum_b += i * hist[i]
			var m_b: = sum_b / w_b
			var m_f: = (sum - sum_b) / w_f
			var between: = float(w_b) * w_f * (m_b - m_f) * (m_b - m_f)
			if between > best:
				best = between
				thr = i + 0.5
		return thr


	func _read_format(bits: PackedByteArray, dim: int) -> Array:
		var a: = 0
		var b: = 0
		for i in 6:
			a |= bits[i * dim + 8] << i
		a |= bits[7 * dim + 8] << 6
		a |= bits[8 * dim + 8] << 7
		a |= bits[8 * dim + 7] << 8
		for i in range(9, 15):
			a |= bits[8 * dim + 14 - i] << i
		for i in 8:
			b |= bits[8 * dim + dim - 1 - i] << i
		for i in range(8, 15):
			b |= bits[(dim - 15 + i) * dim + 8] << i
		var best: = 99
		var out: Array = []
		for e in 4:
			for m in 8:
				var f: = QrCode._format_bits(QrCode._ECL_BITS[e], m)
				var d: = mini(QrCode._popcount(f ^ a), QrCode._popcount(f ^ b))
				if d < best:
					best = d
					out = [e, m]
		return out if best <= 3 else []

	func _read_version(bits: PackedByteArray, dim: int) -> int:
		var a: = 0
		var b: = 0
		for i in 18:
			a |= bits[(i / 3) * dim + dim - 11 + i % 3] << i
			b |= bits[(dim - 11 + i % 3) * dim + i / 3] << i
		var best: = 99
		var said: = 0
		for v in range(7, 41):
			var f: = QrCode._version_bits(v)
			var d: = mini(QrCode._popcount(f ^ a), QrCode._popcount(f ^ b))
			if d < best:
				best = d
				said = v
		return said if best <= 3 else 0


	func _unpack(cw: PackedByteArray, ver: int, ecl: int) -> PackedByteArray:
		var nb: int = QrCode._BLOCKS[ecl][ver]
		var ecc_len: int = QrCode._ECC_PER_BLOCK[ecl][ver]
		var raw: = cw.size()
		var n_short: = nb - raw % nb
		var short_len: = raw / nb
		var stride: = short_len + 1
		var flat: = PackedByteArray()
		flat.resize(nb * stride)
		var k: = 0
		for i in stride:
			for j in nb:
				if i != short_len - ecc_len or j >= n_short:
					flat[j * stride + i] = cw[k]
					k += 1
		var data: = PackedByteArray()
		for j in nb:
			var blk: = flat.slice(j * stride, (j + 1) * stride)
			if j < n_short:
				blk.remove_at(short_len - ecc_len)
			var fixed: = QrCode._rs_fix(blk, ecc_len)
			if fixed.is_empty():
				return PackedByteArray()
			data.append_array(fixed.slice(0, fixed.size() - ecc_len))
		var pos: = 0
		var mode: = _take(data, pos, 4)
		pos += 4
		if mode != 4:
			return PackedByteArray()
		var nbits: = QrCode._count_bits(ver)
		var n: = _take(data, pos, nbits)
		pos += nbits
		if pos + n * 8 > data.size() * 8:
			return PackedByteArray()
		var out: = PackedByteArray()
		for _i in n:
			out.append(_take(data, pos, 8))
			pos += 8
		return out

	static func _take(data: PackedByteArray, pos: int, n: int) -> int:
		var v: = 0
		for i in n:
			var p: = pos + i
			if p >= data.size() * 8:
				return v << (n - i)
			v = (v << 1) | ((data[p >> 3] >> (7 - (p & 7))) & 1)
		return v
