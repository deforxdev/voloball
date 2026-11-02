class_name PlayerFeel
extends Resource






@export var move_speed: = 5.9


@export var accel: = 40.0




@export var accel_start: = 46.0




@export var accel_stop: = 24.0








@export var accel_turn: = 25.0




@export var plant_dot: = -0.2

@export var plant_speed: = 3.4

@export var plant_time: = 0.17

@export var plant_grip: = 0.55



@export var plant_cooldown: = 0.32

@export var gravity: = 22.0

@export var apex_float_threshold: = 3.5

@export var apex_float_factor: = 0.45

@export var fall_gravity_mult: = 1.3



@export var jump_min_velocity: = 7.5



@export var jump_max_velocity: = 11.2



@export var jump_launch_charge: = 0.82



@export var jump_charge_time: = 0.75




@export var jump_spike_buffer: = 0.16





@export var jump_hold_grace: = 1.0
@export var jump_decay_rate: = 1.2







@export var push_radius: = 0.85
@export var push_speed: = 7.0

@export var charge_shake: = 0.035

@export var charge_shake_hz: = 17.0

@export var crouch_squash: = 0.18





@export var launch_stretch: = 0.16
@export var launch_charge_gain: = 0.4


@export var land_pop: = 0.14
@export var launch_spring: = 320.0
@export var launch_damp: = 12.0

@export var knock_time: = 1.0

@export var turn_speed: = 9.4

@export var windup_move_factor: = 0.4




@export var receive_stance_speed: = 0.5




@export var fast_dig_weight: = 0.8

@export var reach: = 1.15
















@export var chest_height: = 1.0

@export var bump_max_ball_height: = 1.5

@export var spike_min_ball_height: = 1.8

@export var max_hold: = 0.8





@export var set_quick_charge: = 1.0





@export var spike_charge_cap: = 1.0
@export var spike_light_power: = 0.25
@export var spike_light_dist: = 4.0










@export var approach_power_floor: = 0.85





@export var approach_ref_speed: = 4.6





@export var serve_approach_floor: = 0.35



@export var serve_approach_ceiling: = 1.25







@export var serve_approach_min: = 2.4
@export var serve_approach_full: = 4.4
@export var serve_approach_curve: = 2.0





@export var approach_power_ceiling: = 1.2


















@export var jump_big_take_charge: = 0.5
@export var bam_delay: = 0.7
@export var bam_lead_time: = 0.25


@export var bam_window: = 0.2



@export var bam_jump_mult: = 1.28






@export var kick_height: = 0.7




@export var approach_min_speed: = 2.5
@export var approach_time: = 0.35
@export var kick_power: = 0.2

@export var air_charge_rate: = 2.2







@export var spike_air_hold: = 0.25

@export var tap_hold: = 0.2

@export var recover_time: = 0.35

@export var whiff_recover_time: = 0.55

@export var receive_window: = 0.55

@export var press_receive_window: = 1.05


@export var set_queue_horizon: = 1.5

@export var set_precharge_reach: = 5.5

@export var set_release_queue_window: = 0.9

@export var contact_queue_steps: = 6

@export var air_queue_horizon: = 0.3

@export var air_lost_horizon: = 0.6






@export var landing_zone_radius: = 1.15

















@export var queue_lost_dist: = 3.8


@export var airborne_lost_margin: = 1.6


@export var receive_reach_bonus: = 0.4

@export var receive_forward: = 0.35












@export var spike_air_reach_bonus: = 0.85




@export var receive_sweep_max: = 1.0

@export var hand_mesh_radius: = 0.14




@export var gaze_near: = 5.0

@export var gaze_far: = 11.0

@export var pose_speed: = 14.0







@export var recoil_kick: = 2.8

@export var recoil_stiff: = 520.0

@export var recoil_damp: = 8.5

@export var air_lean: = 0.3

@export var dump_tilt: = 0.6

@export var block_windup: = 0.08



@export var block_shift_time: = 0.22

@export var block_lane_offset: = 0.8

@export var block_radius: = 0.85

@export var block_height: = 1.7

@export var block_cooldown: = 0.25








@export var block_break_power: = 0.82






@export var block_hold: = 1.18
@export var block_break_late_span: = 0.35
@export var block_late_give: = 0.14
@export var block_offline_give: = 0.45













@export var block_break_at: = 0.7
@export var block_angle_weight: = 1.6











@export var block_break_still_mult: = 0.3
@export var block_break_momentum_from: = 1.0


@export var block_perfect_window: = 0.26




@export var block_back_align: = -0.1





@export var block_late_scatter: = 3.0


@export var dive_speed: = 15.5

@export var dive_time: = 0.5

@export var dive_cooldown: = 5.0


@export var dive_reach: = 1.1


@export var dive_body_length: = 1.45

@export var dive_tilt: = 1.15





@export var tumble_side: = 0.6






@export var tumble_spin_base: = 1.3




@export var tumble_spin_gain: = 3.2


@export var tumble_settle: = 0.35


@export var knock_burnout_hold: = 0.05

@export var tumble_clear: = 1.6




@export var tumble_girth: = 0.24






@export var settle_time: = 2.4

@export var settle_time_hard: = 3.6




@export var land_min_fall: = 2.5

@export var land_pose_min: = 0.16

@export var land_pose_max: = 0.35





@export var idle_still: = 0.6

@export var land_still: = 2.6



@export var stop_speed: = 2.2





@export var getup_time: = 0.55

@export var getup_knock_time: = 0.75





@export var strafe_speed: = 0.88

@export var strafe_accel: = 0.72

@export var strafe_back_speed: = 0.8











@export var strafe_stop: = 2.6

@export var strafe_grip: = 2.2



@export var receive_plant_speed: = 12.0

@export var receive_plant: = 0.72





@export var strafe_receive_heat: = 0.45






@export var receive_anim_speed: = 5.5

@export var receive_pose_min: = 0.3

@export var receive_pose_max: = 0.5





@export var set_pose: = 0.44



@export var receive_side_x: = 0.45




@export var set_min_ball_height: = 0.2




@export var jump_set_down_reach: = 1.35



@export var set_low_height: = 0.85



@export var set_low_push: = 0.0
@export var set_low_lift: = 0.0
@export var set_low_knock: = 0.7


@export var receive_back_z: = 0.4






@export var indicator_color: = Color(0.2, 0.9, 1.0, 1.0)



@export var dive_ring_color: = Color(0.22, 0.92, 0.42, 1.0)

@export var dive_ring_fade: = 0.45







@export var stamina_max: = 100.0



@export var stamina_sprint_drain: = 36.0







@export var stamina_dive_cost: = 45.0



@export var stamina_regen_delay: = 1.2
@export var stamina_regen: = 13.0






@export var stamina_recover_to: = 0.35



@export var stamina_burnout_hold: = 0.5

@export var stamina_recover_regen: = 13.0








@export var stamina_recover_moving: = 0.6



@export var sprint_speed: = 1.25
@export var sprint_speed_empty: = 1.06



@export var sprint_anim_fatigue: = 0.6



@export var sprint_bank: = 0.45


@export var sprint_head_lean: = 0.8



@export var sprint_turn_factor: = 0.45
@export var sprint_grip: = 0.4







@export var sprint_ramp_up: = 5.0
@export var sprint_ramp_down: = 3.0



@export var sprint_plant_speed: = 6.5




@export var jump_carry: = 0.62




@export var jump_sprint_carry: = 1.15





@export var stamina_empty_color: = Color(0.92, 0.18, 0.18, 1.0)
@export var stamina_low_frac: = 0.3

@export var dive_weak_speed: = 0.55
@export var dive_weak_time: = 0.78






@export var reach_coyote: = 0.1



@export var air_arm_window: = 0.35


@export var touch_lock: = 0.12




@export var trip_sweat_min: = 0.55












@export var slip_chance_max: = 0.22
@export var slip_planted_factor: = 0.25
@export var restless_full: = 3.0

@export var trip_chance: = 0.06







@export var float_tilt: = 0.45
@export var float_power_cap: = 0.75




@export var float_shake_from: = 0.15



@export var drive_tilt: = 0.45
@export var drive_power_bonus: = 0.15
@export var float_shake_speed: = 0.12
@export var float_slip_speed: = 0.6
@export var float_shake_angle: = 0.7
@export var float_shake_dist: = 0.35

@export var ring_jump: = Color(0.4, 0.95, 0.35, 1.0)

@export var ring_serve: = Color(1.0, 0.85, 0.3, 1.0)
