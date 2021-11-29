% this file takes in a motor int eh style of the laser_auto_vector_gui and
% performs the motion.  It is to make code cleaner.

function motor_perform_step(motor_in,step_value_in)

motor_step_PV = [motor_in,':MOTOR.TWV'];
motor_jump_PV = [motor_in,':MOTOR.TWF'];
lcaPut(motor_step_PV,step_value_in)
lcaPut(motor_jump_PV,1)