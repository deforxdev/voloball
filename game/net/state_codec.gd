class_name StateCodec














const SCALE: = 100.0
const Q_MAX: = 327.67


const F_BALL: = 1
const F_BODIES: = 2
const F_CLOCKS: = 4

static func _q(v: float) -> int:
	return int(roundf(clampf(v, - Q_MAX, Q_MAX) * SCALE))

static func encode_snapshot(d: Dictionary) -> PackedByteArray:
	var buf: = StreamPeerBuffer.new()
	buf.big_endian = false
	var flags: = 0
	if d.has("b"):
		flags |= F_BALL
	if d.has("p"):
		flags |= F_BODIES
	if d.has("sc"):
		flags |= F_CLOCKS
	buf.put_u8(4)
	buf.put_u8(flags)
	buf.put_u8(int(d.get("ph", 0)))
	buf.put_u8(int(d.get("s1", 0)))
	buf.put_u8(int(d.get("s2", 0)))
	buf.put_u8(int(d.get("w1", 0)))
	buf.put_u8(int(d.get("w2", 0)))
	buf.put_u8(int(d.get("sn", 1)))
	buf.put_u32(int(d.get("sq", 0)))





	buf.put_u32(int(d.get("g", 0)) & 4294967295)
	if flags & F_CLOCKS:
		buf.put_16(_q(float(d.get("sc", 0.0))))
		buf.put_16(_q(float(d.get("rt", 0.0))))
		buf.put_u8(int(d.get("tc", 0)))
		buf.put_u16(int(d.get("sv", 0)))
		buf.put_u16(int(d.get("lt", 0)))
		buf.put_u8(1 if bool(d.get("sd", false)) else 0)
	if flags & F_BALL:
		var b: PackedFloat32Array = d.b
		for i in 8:
			buf.put_16(_q(b[i]))
		buf.put_u32(int(b[8]))

		buf.put_16(_q(b[9] if b.size() >= 10 else Ball.STOP_NONE))
	if flags & F_BODIES:
		var p: PackedFloat32Array = d.p
		var count: = p.size() / ReplayData.NET_PLAYER_FLOATS
		buf.put_u8(count)
		for i in p.size():



			if i % ReplayData.NET_PLAYER_FLOATS == 11 or i % ReplayData.NET_PLAYER_FLOATS == 24:
				buf.put_u32(int(p[i]))
			else:
				buf.put_16(_q(p[i]))
	var acks: Dictionary = d.get("ack", {})
	buf.put_u8(acks.size())
	for id in acks:






		buf.put_64(int(id))
		buf.put_u32(int(acks[id]))
	return buf.data_array

static func decode_snapshot(bytes: PackedByteArray) -> Dictionary:
	var buf: = StreamPeerBuffer.new()
	buf.big_endian = false
	buf.data_array = bytes
	if buf.get_u8() != 4:
		return {}
	var flags: = buf.get_u8()
	var d: = {
		"ph": buf.get_u8(), 
		"s1": buf.get_u8(), "s2": buf.get_u8(), 
		"w1": buf.get_u8(), "w2": buf.get_u8(), 
		"sn": buf.get_u8(), 
		"sq": buf.get_u32(), 
		"g": buf.get_u32(), 
	}
	if flags & F_CLOCKS:
		d["sc"] = buf.get_16() / SCALE
		d["rt"] = buf.get_16() / SCALE
		d["tc"] = buf.get_u8()
		d["sv"] = buf.get_u16()
		d["lt"] = buf.get_u16()
		d["sd"] = buf.get_u8() == 1
	if flags & F_BALL:
		var b: = PackedFloat32Array()
		b.resize(10)
		for i in 8:
			b[i] = buf.get_16() / SCALE
		b[8] = float(buf.get_u32())
		b[9] = buf.get_16() / SCALE
		d["b"] = b
	if flags & F_BODIES:
		var count: = buf.get_u8()
		var p: = PackedFloat32Array()
		p.resize(count * ReplayData.NET_PLAYER_FLOATS)
		for i in p.size():
			if i % ReplayData.NET_PLAYER_FLOATS == 11 or i % ReplayData.NET_PLAYER_FLOATS == 24:
				p[i] = float(buf.get_u32())
			else:
				p[i] = buf.get_16() / SCALE
		d["p"] = p
	var acks: = {}
	for i in buf.get_u8():
		var id: = buf.get_64()
		acks[id] = buf.get_u32()
	d["ack"] = acks
	return d
