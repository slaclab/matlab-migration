function const = util_UndulatorConstants
% util_UndulatorsConstants provides reference values for the most commonly
%       used constants of the LCLS undulator system.
%
%       Usage:
%       const    = util_UndulatorConstants;
%       lambda_r = 1.5e-10;
%       gamma    = sqrt ( const.lambda_u / ( 2 * lambda_r ) * ( 1 + const.K_nominal^2/2 ) );
%
%       Function last edited January 27, 2010 by HDN

const.lambda_u            = 0.03;                                                                 % m
const.K_nominal           = 3.5;                                                                  % m
const.maxSegments         = 33;
const.SegmentPeriods      = 113;
const.UndulatorPeriods    = const.SegmentPeriods * const.maxSegments;
const.shortBreakLength    = 0.470;                                                                % m
const.longBreakLength     = 0.898;                                                                % m
const.shortBreakCount     = 22;
const.longBreakCount      = 10;
const.SegmentLength       = 3.40;                                                                 % m
const.UndulatorLength     = const.maxSegments     * const.SegmentLength     + ...                 % m
                            const.longBreakCount  * const.longBreakLength   + ...
                            const.shortBreakCount * const.shortBreakLength;
const.Girder_US_cam_dx    = 0.0018;                                                               % m
const.Girder_US_cam_dy    = 0.0018;                                                               % m
const.Girder_US_cam_dz    = 0.0000;                                                               % m
const.Girder_DS_cam_dx    = 0.0018;                                                               % m
const.Girder_DS_cam_dy    = 0.0018;                                                               % m
const.Girder_DS_cam_dz    = 0.0000;                                                               % m
const.Girder_cams_sep     = 2.343;                                                                % m
const.Girder_cam_quad_sep = 2.985 - const.Girder_cams_sep;                                        % m

const.Z_BLM {  1 } = 515.300982;
const.Z_BLM {  2 } = 519.170982;
const.Z_BLM {  3 } = 523.040982;
const.Z_BLM {  4 } = 527.338982;
const.Z_BLM {  5 } = 531.208982;
const.Z_BLM {  6 } = 535.078982;
const.Z_BLM {  7 } = 539.376982;
const.Z_BLM {  8 } = 543.246982;
const.Z_BLM {  9 } = 547.116982;
const.Z_BLM { 10 } = 551.414982;
const.Z_BLM { 11 } = 555.284982;
const.Z_BLM { 12 } = 559.154982;
const.Z_BLM { 13 } = 563.452982;
const.Z_BLM { 14 } = 567.322982;
const.Z_BLM { 15 } = 571.192982;
const.Z_BLM { 16 } = 575.490982;
const.Z_BLM { 17 } = 579.360982;
const.Z_BLM { 18 } = 583.230982;
const.Z_BLM { 19 } = 587.528982;
const.Z_BLM { 20 } = 591.398982;
const.Z_BLM { 21 } = 595.268982;
const.Z_BLM { 22 } = 599.566982;
const.Z_BLM { 23 } = 603.436982;
const.Z_BLM { 24 } = 607.306982;
const.Z_BLM { 25 } = 611.604982;
const.Z_BLM { 26 } = 615.474982;
const.Z_BLM { 27 } = 619.344982;
const.Z_BLM { 28 } = 623.642982;
const.Z_BLM { 29 } = 627.512982;
const.Z_BLM { 30 } = 631.382982;
const.Z_BLM { 31 } = 635.680982;
const.Z_BLM { 32 } = 639.550982;
const.Z_BLM { 33 } = 643.420982;
const.Z_BFW {  1 } = 515.229032;
const.Z_BFW {  2 } = 519.099032;
const.Z_BFW {  3 } = 522.969032;
const.Z_BFW {  4 } = 527.267032;
const.Z_BFW {  5 } = 531.137032;
const.Z_BFW {  6 } = 535.007032;
const.Z_BFW {  7 } = 539.305032;
const.Z_BFW {  8 } = 543.175032;
const.Z_BFW {  9 } = 547.045032;
const.Z_BFW { 10 } = 551.343032;
const.Z_BFW { 11 } = 555.213032;
const.Z_BFW { 12 } = 559.083032;
const.Z_BFW { 13 } = 563.381032;
const.Z_BFW { 14 } = 567.251032;
const.Z_BFW { 15 } = 571.121032;
const.Z_BFW { 16 } = 575.419032;
const.Z_BFW { 17 } = 579.289032;
const.Z_BFW { 18 } = 583.159032;
const.Z_BFW { 19 } = 587.457032;
const.Z_BFW { 20 } = 591.327032;
const.Z_BFW { 21 } = 595.197032;
const.Z_BFW { 22 } = 599.495032;
const.Z_BFW { 23 } = 603.365032;
const.Z_BFW { 24 } = 607.235032;
const.Z_BFW { 25 } = 611.533032;
const.Z_BFW { 26 } = 615.403032;
const.Z_BFW { 27 } = 619.273032;
const.Z_BFW { 28 } = 623.571032;
const.Z_BFW { 29 } = 627.441032;
const.Z_BFW { 30 } = 631.311032;
const.Z_BFW { 31 } = 635.609032;
const.Z_BFW { 32 } = 639.479032;
const.Z_BFW { 33 } = 643.349032;
const.Z_QUAD {  1 } = 518.867892;
const.Z_QUAD {  3 } = 526.607892;
const.Z_QUAD {  5 } = 534.775892;
const.Z_QUAD {  7 } = 542.943892;
const.Z_QUAD {  9 } = 550.683892;
const.Z_QUAD { 11 } = 558.851892;
const.Z_QUAD { 13 } = 567.019892;
const.Z_QUAD { 15 } = 574.759892;
const.Z_QUAD { 17 } = 582.927892;
const.Z_QUAD { 19 } = 591.095892;
const.Z_QUAD { 21 } = 598.835892;
const.Z_QUAD { 23 } = 607.003892;
const.Z_QUAD { 25 } = 615.171892;
const.Z_QUAD { 27 } = 622.911892;
const.Z_QUAD { 29 } = 631.079892;
const.Z_QUAD { 31 } = 639.247892;
const.Z_QUAD { 33 } = 646.987892;
const.Z_QUAD {  2 } = 522.737182;
const.Z_QUAD {  4 } = 530.905892;
const.Z_QUAD {  6 } = 538.645892;
const.Z_QUAD {  8 } = 546.813892;
const.Z_QUAD { 10 } = 554.981892;
const.Z_QUAD { 12 } = 562.721892;
const.Z_QUAD { 14 } = 570.889892;
const.Z_QUAD { 16 } = 579.057892;
const.Z_QUAD { 18 } = 586.797892;
const.Z_QUAD { 20 } = 594.965892;
const.Z_QUAD { 22 } = 603.133892;
const.Z_QUAD { 24 } = 610.873892;
const.Z_QUAD { 26 } = 619.041892;
const.Z_QUAD { 28 } = 627.209892;
const.Z_QUAD { 30 } = 634.949892;
const.Z_QUAD { 32 } = 643.117892;
const.Z_BPM {  1 } = 518.998062;
const.Z_BPM {  2 } = 522.867292;
const.Z_BPM {  3 } = 526.738062;
const.Z_BPM {  4 } = 531.036062;
const.Z_BPM {  5 } = 534.906062;
const.Z_BPM {  6 } = 538.776062;
const.Z_BPM {  7 } = 543.074062;
const.Z_BPM {  8 } = 546.944062;
const.Z_BPM {  9 } = 550.814062;
const.Z_BPM { 10 } = 555.112062;
const.Z_BPM { 11 } = 558.982062;
const.Z_BPM { 12 } = 562.852062;
const.Z_BPM { 13 } = 567.150062;
const.Z_BPM { 14 } = 571.020062;
const.Z_BPM { 15 } = 574.890062;
const.Z_BPM { 16 } = 579.188062;
const.Z_BPM { 17 } = 583.058062;
const.Z_BPM { 18 } = 586.928062;
const.Z_BPM { 19 } = 591.226062;
const.Z_BPM { 20 } = 595.096062;
const.Z_BPM { 21 } = 598.966062;
const.Z_BPM { 22 } = 603.264062;
const.Z_BPM { 23 } = 607.134062;
const.Z_BPM { 24 } = 611.004062;
const.Z_BPM { 25 } = 615.302062;
const.Z_BPM { 26 } = 619.172062;
const.Z_BPM { 27 } = 623.042062;
const.Z_BPM { 28 } = 627.340062;
const.Z_BPM { 29 } = 631.210062;
const.Z_BPM { 30 } = 635.080062;
const.Z_BPM { 31 } = 639.378062;
const.Z_BPM { 32 } = 643.248062;
const.Z_BPM { 33 } = 647.118062;
const.Z_BPM { 34 } = 658.703261;
const.Z_US { 1 } = 517.059292;
const.Z_US { 2 } = 520.929292;
const.Z_US { 3 } = 524.799292;
const.Z_US { 4 } = 529.097292;
const.Z_US { 5 } = 532.967292;
const.Z_US { 6 } = 536.837292;
const.Z_US { 7 } = 541.135292;
const.Z_US { 8 } = 545.005292;
const.Z_US { 9 } = 548.875292;
const.Z_US { 10 } = 553.173292;
const.Z_US { 11 } = 557.043292;
const.Z_US { 12 } = 560.913292;
const.Z_US { 13 } = 565.211292;
const.Z_US { 14 } = 569.081292;
const.Z_US { 15 } = 572.951292;
const.Z_US { 16 } = 577.249292;
const.Z_US { 17 } = 581.119292;
const.Z_US { 18 } = 584.989292;
const.Z_US { 19 } = 589.287292;
const.Z_US { 20 } = 593.157292;
const.Z_US { 21 } = 597.027292;
const.Z_US { 22 } = 601.325292;
const.Z_US { 23 } = 605.195292;
const.Z_US { 24 } = 609.065292;
const.Z_US { 25 } = 613.363292;
const.Z_US { 26 } = 617.233292;
const.Z_US { 27 } = 621.103292;
const.Z_US { 28 } = 625.401292;
const.Z_US { 29 } = 629.271292;
const.Z_US { 30 } = 633.141292;
const.Z_US { 31 } = 637.439292;
const.Z_US { 32 } = 641.309292;
const.Z_US { 33 } = 645.179292;


end