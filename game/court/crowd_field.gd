class_name CrowdField
extends MultiMeshInstance3D






static var _active: CrowdField = null

const QUIET_AFTER: = 4.0

var _mat: ShaderMaterial = null
var _cheer_t: = 999.0
var _cheer_amt: = 0.0
var _shock_t: = 999.0
var _shock_amt: = 0.0
var _time: = 0.0

func bind(mat: ShaderMaterial) -> void :
	_mat = mat
	_active = self
	set_process(true)

func _process(delta: float) -> void :
	if _mat == null:
		return
	_time += delta
	_param("crowd_time", _time)
	if _cheer_amt > 0.0:
		_cheer_t += delta
		_param("cheer_elapsed", _cheer_t)
		if _cheer_t > QUIET_AFTER:
			_cheer_amt = 0.0
			_param("cheer_intensity", 0.0)
	if _shock_amt > 0.0:
		_shock_t += delta
		_param("shock_elapsed", _shock_t)
		if _shock_t > QUIET_AFTER:
			_shock_amt = 0.0
			_param("shock_intensity", 0.0)


func _param(param: StringName, value: Variant) -> void :
	_mat.set_shader_parameter(param, value)
	if _mat.next_pass is ShaderMaterial:
		(_mat.next_pass as ShaderMaterial).set_shader_parameter(param, value)

func _exit_tree() -> void :
	if _active == self:
		_active = null

func _cheer(intensity: float) -> void :
	if _mat == null:
		return
	intensity = clampf(intensity, 0.0, 1.0)


	if _cheer_amt > 0.0 and _cheer_t < 1.2 and intensity <= _cheer_amt:
		return
	_cheer_t = 0.0
	_cheer_amt = intensity
	_param("cheer_elapsed", 0.0)
	_param("cheer_intensity", intensity)

func _shock(intensity: float) -> void :
	if _mat == null:
		return
	intensity = clampf(intensity, 0.0, 1.0)
	if _shock_amt > 0.0 and _shock_t < 0.5 and intensity <= _shock_amt:
		return
	_shock_t = 0.0
	_shock_amt = intensity
	_param("shock_elapsed", 0.0)
	_param("shock_intensity", intensity)


static func cheer(intensity: float) -> void :
	if _active != null:
		_active._cheer(intensity)

static func shock(intensity: float) -> void :
	if _active != null:
		_active._shock(intensity)




static func calm() -> void :
	if _active != null:
		_active._calm()

func _calm() -> void :
	_cheer_amt = 0.0
	_shock_amt = 0.0
	_cheer_t = 999.0
	_shock_t = 999.0
	if _mat != null:
		_param("cheer_intensity", 0.0)
		_param("shock_intensity", 0.0)
