function jaw = collimatorJawData( ename )
%
% Return the all current jaw positions values for any collimator 'ename'.
% xJaw and yJaw are structures. xJaw.pos.lvdt, for example, are all the
% positive jaw positions in millimeters. "x" is horizonatal and positive is
% northward following the linac coordinate system.  The position returned
% is either according to the LVDT or to the Motor record.
%
% 'ename' is the name of the collimator given in the MAD deck. 
% MAD names for the collimators can be obtained one at a time by, e.g.
%     meme_names('name', pvHnegLVDT{1}, 'show', 'ename')


jaw =[]; % initialize

%
% "Linac" Collimators: 4-jaw and Cu chicanes:  different and variable data
% structure! unit numbers 46, 47 for H; 48 and 49 for V. No temperature
% data for Linac collimators
%

switch char(ename)
    
    case 'C29096'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI28:917:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI28:917:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI28:916:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI28:916:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI28:918:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI28:918:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI28:919:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI28:919:MOTR');
        
    case  'C29146'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI29:147:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI29:147:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI29:146:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI29:146:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI29:148:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI29:148:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI29:149:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI29:149:MOTR');
        
    case  'C29446'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI29:447:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI29:447:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI29:446:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI29:446:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI29:448:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI29:448:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI29:449:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI29:449:MOTR');
        
    case  'C29546'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI29:547:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI29:547:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI29:546:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI29:546:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI29:548:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI29:548:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI29:549:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI29:549:MOTR');
        
    case  'C29956'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI29:957:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI29:957:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI29:956:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI29:956:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI29:958:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI29:958:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI29:959:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI29:959:MOTR');
        
    case  'C30146'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI30:147:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI30:147:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI30:146:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI30:146:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI30:148:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI30:148:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI30:149:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI30:149:MOTR');
        
    case  'C30446'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI30:447:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI30:447:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI30:446:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI30:446:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI30:448:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI30:448:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI30:449:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI30:449:MOTR');
        
    case 'C30546'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI30:547:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI30:547:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI30:546:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI30:546:MOTR');
        
        jaw.posy.lvdt = lcaGet(  'COLL:LI30:548:LVPOS');
        jaw.posy.motor = lcaGet( 'COLL:LI30:548:MOTR');
        jaw.negy.lvdt = lcaGet(  'COLL:LI30:549:LVPOS');
        jaw.negy.motor = lcaGet( 'COLL:LI30:549:MOTR');
        
    case 'CE11'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI21:236:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI21:236:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI21:235:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI21:235:MOTR');
        
    case 'CE21'
        jaw.posx.lvdt =  lcaGet( 'COLL:LI24:806:LVPOS');
        jaw.posx.motor = lcaGet( 'COLL:LI24:806:MOTR');
        jaw.negx.lvdt =  lcaGet( 'COLL:LI24:805:LVPOS');
        jaw.negx.motor = lcaGet( 'COLL:LI24:805:MOTR');
        
    case 'CEDL1' % Final HXR Energy
        jaw.posx.lvdt =  lcaGet('COLL:LTUH:253:POSX:LVPOS');
        jaw.posx.motor = lcaGet('COLL:LTUH:253:POSX:MOTR');
        jaw.negx.lvdt =  lcaGet('COLL:LTUH:253:NEGX:LVPOS');
        jaw.negx.motor =  lcaGet('COLL:LTUH:253:POSX:MOTR');
    case 'CEDL3' % Final HXR Energy
        jaw.posx.lvdt =  lcaGet('COLL:LTUH:452:POSX:LVPOS');
        jaw.posx.motor = lcaGet('COLL:LTUH:452:POSX:MOTR');
        jaw.negx.lvdt =  lcaGet('COLL:LTUH:452:NEGX:LVPOS');
        jaw.negx.motor =  lcaGet('COLL:LTUH:452:POSX:MOTR');
        %
    case 'CYBX36' % Final HXR Vertical % CYBX32 is deferred July 2020
        jaw.posy.lvdt=lcaGet('COLL:LTUH:475:POSY:LVPOS');
        jaw.posy.motor=lcaGet('COLL:LTUH:475:POSY:MOTR');
        jaw.negy.lvdt=lcaGet('COLL:LTUH:475:NEGY:LVPOS');
        jaw.negy.motor=lcaGet('COLL:LTUH:475:NEGY:MOTR');
        
    case 'CXQT22' % Final HXR Horizontal %  'CXQ6'is deferred July 2020
        jaw.posx.lvdt=lcaGet('COLL:LTUH:393:POSX:LVPOS');
        jaw.posx.motor=lcaGet('COLL:LTUH:393:POSX:MOTR');
        jaw.negx.lvdt=lcaGet('COLL:LTUH:393:NEGX:LVPOS');
        jaw.negx.motor=lcaGet('COLL:LTUH:393:NEGX:MOTR');
        %
    case 'CEDL13' % Final SXR Energy
        jaw.posx.lvdt =  lcaGet('COLL:LTUS:235:POSX:LVPOS');
        jaw.posx.motor = lcaGet('COLL:LTUS:235:POSX:MOTR');
        jaw.negx.lvdt =  lcaGet('COLL:LTUS:235:NEGX:LVPOS');
        jaw.negx.motor =  lcaGet('COLL:LTUS:235:POSX:MOTR');
    case 'CEDL17' % Final SXR Energy
        jaw.posx.lvdt =  lcaGet('COLL:LTUS:372:POSX:LVPOS');
        jaw.posx.motor = lcaGet('COLL:LTUS:372:POSX:MOTR');
        jaw.negx.lvdt =  lcaGet('COLL:LTUS:372:NEGX:LVPOS');
        jaw.negx.motor =  lcaGet('COLL:LTUS:372:POSX:MOTR');
        
    case 'CYDL16' % Final SXR Vertical
        jaw.posy.lvdt=lcaGet('COLL:LTUS:345:POSY:LVPOS');
        jaw.posy.motor=lcaGet('COLL:LTUS:345:POSY:MOTR');
        jaw.negy.lvdt=lcaGet('COLL:LTUS:345:NEGY:LVPOS');
        jaw.negy.motor=lcaGet('COLL:LTUS:345:NEGY:MOTR');
        
    case 'CXBP34' % Final SXR Horizontal
        jaw.posx.lvdt=lcaGet('COLL:BSYS:859:POSX:LVPOS');
        jaw.posx.motor=lcaGet('COLL:BSYS:859:POSX:MOTR');
        jaw.negx.lvdt=lcaGet('COLL:BSYS:859:NEGX:LVPOS');
        jaw.negx.motor=lcaGet('COLL:BSYS:859:NEGX:MOTR');
        
 %%%%% commented out collimators that  do not yet exist as PVs, July 2020
        
        %     case 'CEHTR' %  laser heater energy
        %
        %     case 'CYC01' % vert SC laser heater
        %     case 'CYC03' % vert SC laser heater
        %
        %     case 'CXC01' % Horizontal SC laser heater
        %     case 'CXC03' % Horizontal SC laser heater
        %
        %     case 'CE11B' % SC BC1/2 ENERGY
        %     case 'CE21B' % SC BC1/2 ENERGY
        %
        %     case 'CYC11' % SC BC1/2 vertical
        %     case 'CYC113' % SC BC1/2 vertical
        %
        %     case 'CXC11' % SC BC1/2 horizontal
        %     case 'CXC13' % SC BC1/2 horizontal
        %
        %     case 'CEDOG' % SC BYPASS energy
        %
        %     case 'CYBP22' % SC BYPASS VERTICAL
        %     case 'CYBP26' % SC BYPASS VERTICAL
        %
        %     case 'CXBP22' % SC BYPASS HORIZONTAL
        %     case 'CXBP26' % SC BYPASS HORIZONTAL
        
        %     case 'CYBDL' % Final SXR Vertical
        
        %     case 'CXBP30' % Final SXR Horizontal
        
end


