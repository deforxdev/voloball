class_name BallPhysics
extends Resource






@export var radius: = 0.26

@export var gravity: = 11.0




@export var serve_toss_horiz_max: = 3.5
@export var serve_toss_net_margin: = 1.2





@export var serve_toss_min: = 10.0
@export var serve_toss_max: = 15.0

@export var floor_bounce: = 0.5

@export var floor_friction: = 0.75

@export var roll_drag: = 4.0

@export var net_height: = 2.2










@export var spike_lock_free: = 15.0
@export var spike_lock_gain: = 0.09
@export var spike_lock_max: = 0.7



@export var spike_lock_min: = 0.5

@export var quick_arrive_h: = 4.0




@export var set_arrive_h: = 3.0









@export var tape_band: = 0.1






@export var tape_pop_base: = 2.6
@export var tape_pop_gain: = 0.14
@export var tape_pop_min: = 3.4
@export var tape_pop_max: = 5.6



@export var net_catch_keep: = 0.25
@export var net_back_spring: = 0.07

@export var tape_drift: = 0.35
@export var tape_side_damp: = 0.15

@export var net_half_width: = 4.7
@export var antenna_half_width: = 4.5



@export var antenna_radius: = 0.42
@export var antenna_rise: = 1.0





@export var tool_keep: = 0.6

@export var tool_bleed: = 0.014

@export var tool_keep_min: = 0.28

@export var tool_smear: = 4.0

@export var tool_max_speed: = 8.0

@export var tool_lift: = 2.2

@export var tool_lift_gain: = 0.06







@export var block_soft_power: = 0.4
@export var block_hard_power: = 0.7
@export var block_flat_vy: = -1.0
@export var block_rebound_vy: = 3.5
@export var block_soft_keep: = 0.5
@export var block_soft_max: = 4.5







@export var carom_height: = 0.55

@export var carom_radius: = 0.6

@export var carom_keep: = 0.45

@export var carom_max_speed: = 6.5





@export var carom_lift: = 3.0

@export var carom_lift_gain: = 0.25

@export var carom_lift_max: = 7.0

@export var carom_scatter: = 0.6

@export var carom_hard_speed: = 11.0







@export var body_radius: = 0.3
@export var body_height: = 1.3
@export var body_keep_soft: = 0.15
@export var body_keep_hard: = 0.35


@export var body_min_speed: = 1.2
@export var body_max_speed: = 11.0
@export var body_lift: = 1.5
@export var body_lift_gain: = 0.12
@export var body_lift_max: = 5.0
@export var body_scatter: = 0.4
@export var body_speed_jitter: = 0.2

@export var trail_min_speed: = 5.0








@export var spike_min_speed: = 4.0







@export var spike_speed_slow: = 8.0




@export var tip_rise: = 1.3
@export var tip_drop_gravity: = 2.8
@export var tip_drop_blend: = 4.0
@export var spike_speed_fast: = 30.0




@export var spike_overdrive_max: = 1.45
@export var spike_min_flight: = 0.1
@export var spike_min_flight_slow: = 0.5

@export var dump_min_speed: = 7.0

@export var pass_max_speed: = 12.0

@export var quick_set_max_speed: = 34.0













@export var set_near_dist: = 1.4
@export var set_far_dist: = 5.0
@export var set_near_full_time: = 2.5












@export var attack_clear_soft: = 0.8
@export var attack_clear_tight: = 0.04
@export var pass_clear_margin: = 0.35







@export var serve_clear_tight: = 0.14




@export var serve_clear_soft: = 1.6







@export var serve_time_slow: = 1.3
@export var serve_time_fast: = 0.55
@export var serve_power_slow: = 0.35
@export var serve_power_fast: = 1.35
@export var serve_dive_max: = 2.6




@export var curve_strength: = 12.0
@export var curve_ref_speed: = 13.0







@export var curve_decay_time: = 0.5









@export var float_serve_time_slow: = 1.6
@export var float_serve_time_fast: = 1.3
@export var float_time_factor: = 1.25

@export var drive_time_factor: = 0.85






@export var outline_home: = Color(0.35, 1.0, 0.55)

@export var outline_away: = Color(1.0, 0.25, 0.72)









@export var outline_contested: = Color(0.72, 0.72, 0.76)
@export var contest_band: = 0.26
@export var contest_min_vz: = 0.5




@export var trail_fast: = Color(0.34, 0.8, 1.0)
@export var trail_fast_speed: = 13.0








@export var magnet_lean_max: = 0.12
