import cx_Oracle
import epics
import time
import datetime
import re
import string
import decimal
import numpy as np

now=datetime.datetime.now()

 
db = cx_Oracle.connect("/@SLACPROD")
cursor = db.cursor()
#cursor.prepare('select * from beam_request_params where END_DATE>=:now')
#cursor.execute('select * from beam_request_params where instr(END_DATE)>=:now')
#cursor.execute("SELECT * FROM BEAM_REQUEST_PARAMS WHERE ")
#cursor.execute('SELECT * FROM BEAM_REQUEST_PARAMS')
cursor.execute('SELECT * FROM BEAM_REQUEST_PARAMS ORDER BY END_DATE')

#cursor.execute('SELECT * FROM (SELECT * FROM BEAM_REQUEST_PARAMS ORDER BY END_DATE) WHERE rownum<5')
#cursor.execute('SELECT * FROM (SELECT * FROM BEAM_REQUEST_PARAMS ORDER BY END_DATE) INSTR(END_DATE)>=:now')
#cursor.execute(None)
#cursor.arraysize = 4
#cursor.execute('SELECT * FROM BEAM_REQUEST_PARAMS ORDER BY END_DATE')
#rows = cursor.fetchmany(numRows=7) 
rows = cursor.fetchall()
#print cursor.bindnames()

for row in rows:
     list([rows])
     list.sort(rows)
     list.reverse(rows)
     A = np.array([rows[0],])
     B = np.array([rows[1],])
     C = np.array([rows[2],])
     D = np.array([rows[3],])
     #print row
     #print A
     #print B
     #print C
     #print D

for row in A: 
     t1= row[1]
     strt1 =(t1-datetime.datetime(1970,1,1)).total_seconds()
     te1= row[2]
     end1 =(te1-datetime.datetime(1970,1,1)).total_seconds()
     sh1= row[4]
     hut1 = row[5]   
     #xen1 = re.findall('[0-9.]+', row[6]) # capture the inner number only
     xen1 = row[6]
     xenp1 =str('N' if row[7] is None else row[7])
     bl1= str(0 if row[8] is None else row[8])
     blp1=str('N' if row[9] is None else row[9])
     mfel1=str(0 if row[10] is None else row[10])
     mfelp1=str('N' if row[11] is None else row[11])
     chrg1=str(0 if row[12] is None else row[12])
     chrgp1=str('N' if row[13] is None else row[13])
     bw1=str(0 if row[14] is None else row[14])
     bwp1=str('N' if row[15] is None else row[15])
     pr1=str(0 if row[16] is None else row[16])
     prp1=str('N' if row[17] is None else row[17])
     
for row in B:    
     t2= row[1]
     strt2 =(t2-datetime.datetime(1970,1,1)).total_seconds()
     te2= row[2]
     end2 =(te2-datetime.datetime(1970,1,1)).total_seconds()
     sh2 = row[4]
     hut2 = row[5]
     #xen2 = re.findall('[0-9.]+', row[6]) # capture the inner number only
     xen2 = row[6]
     xenp2 = str('N' if row[7] is None else row[7])
     bl2=str(0 if row[8] is None else row[8])
     blp2=str('N' if row[9] is None else row[9])
     mfel2=str(0 if row[10] is None else row[10])
     mfelp2=str('N' if row[11] is None else row[11])
     chrg2=str(0 if row[12] is None else row[12])
     chrgp2=str('N' if row[13] is None else row[13])
     bw2=str(0 if row[14] is None else row[14])
     bwp2=str('N' if row[15] is None else row[15])
     pr2=str(0 if row[16] is None else row[16])
     prp2=str('N' if row[17] is None else row[17])
   
for row in C:
     t3= row[1]
     strt3=(t3-datetime.datetime(1970,1,1)).total_seconds()
     te3= row[2]
     end3 =(te3-datetime.datetime(1970,1,1)).total_seconds()
     sh3 = row[4]
     hut3 = row[5]
     #xen3 = re.findall('[0-9.]+', row[6]) # capture the inner number only
     xen3 = row[6]
     xenp3 = str('N' if row[7] is None else row[7])
     bl3=str(0 if row[8] is None else row[8])
     blp3=str('N' if row[9] is None else row[9])
     mfel3=str(0 if row[10] is None else row[10])
     mfelp3=str('N' if row[11] is None else row[11])
     chrg3=str(0 if row[12] is None else row[12])
     chrgp3=str('N' if row[13] is None else row[13])
     bw3=str(0 if row[14] is None else row[14])
     bwp3=str('N' if row[15] is None else row[15])
     pr3=str(0 if row[16] is None else row[16])
     prp3=str('N' if row[17] is None else row[17])

for row in D:
     t4= row[1]
     strt4 =(t4-datetime.datetime(1970,1,1)).total_seconds()
     te4= row[2]
     end4 =(te4-datetime.datetime(1970,1,1)).total_seconds()
     sh4 = row[4]
     hut4 = row[5]
     #xen4 = re.findall('[0-9.]+', row[6]) # capture the inner number only
     xen4 = row[6]
     xenp4 = str('N' if row[7] is None else row[7])
     bl4=str(0 if row[8] is None else row[8])
     blp4=str('N' if row[9] is None else row[9])
     mfel4=str(0 if row[10] is None else row[10])
     mfelp4=str('N' if row[11] is None else row[11])
     chrg4=str(0 if row[12] is None else row[12])
     chrgp4=str('N' if row[13] is None else row[13])
     bw4=str(0 if row[14] is None else row[14])
     bwp4=str('N' if row[15] is None else row[15])
     pr4=str(0 if row[16] is None else row[16])
     prp4=str('N' if row[17] is None else row[17])
         

#print(cursor.description)
pv1 = epics.PV('SIOC:SYS0:ML03:AO001') #startdate1
pv17 = epics.PV('SIOC:SYS0:ML03:AO017') #startdate2
pv33 = epics.PV('SIOC:SYS0:ML03:AO033') #startdate3
pv49 = epics.PV('SIOC:SYS0:ML03:AO049') #startdate4
#print pv1.get() 
pv1.put(strt1)
#print pv1.get() 
pv17.put(strt2)
#print pv17.get() 
pv33.put(strt3)
#print pv33.get() 
pv49.put(strt4)
#print pv49.get()

pv2 = epics.PV('SIOC:SYS0:ML03:AO002') #enddate1
pv18 = epics.PV('SIOC:SYS0:ML03:AO018') #enddate2
pv34 = epics.PV('SIOC:SYS0:ML03:AO034') #enddate3
pv50 = epics.PV('SIOC:SYS0:ML03:AO050') #enddate4
pv2.put(end1)
#print pv2.get()
pv18.put(end2)
#print pv18.get()
pv34.put(end3)
#print pv34.get()
pv50.put(end4)
#print pv50.get()

pv3 = epics.PV('SIOC:SYS0:ML03:AO003.DESC') #shift1
pv19 = epics.PV('SIOC:SYS0:ML03:AO019.DESC') #shift2
pv35 = epics.PV('SIOC:SYS0:ML03:AO035.DESC') #shift3
pv51 = epics.PV('SIOC:SYS0:ML03:AO051.DESC') #shift4
pv3.put(sh1)
print pv3.get()
pv19.put(sh2)
print pv19.get()
pv35.put(sh3)
print pv35.get()
pv51.put(sh4)
print pv51.get()


pv4 = epics.PV('SIOC:SYS0:ML03:AO004.DESC') #hutch1
pv20 = epics.PV('SIOC:SYS0:ML03:AO020.DESC') #hutch2
pv36 = epics.PV('SIOC:SYS0:ML03:AO036.DESC') #hutch3
pv52 = epics.PV('SIOC:SYS0:ML03:AO052.DESC') #hutch4
pv4.put(hut1)
print pv4.get()
pv20.put(hut2)
print pv20.get()
pv36.put(hut3)
print pv36.get()
pv52.put(hut4)
print pv52.get()


pv5 = epics.PV('SIOC:SYS0:ML03:AO005.DESC') #x-ray_energy1
pv21 = epics.PV('SIOC:SYS0:ML03:AO021.DESC') #x-ray_energy2
pv37 = epics.PV('SIOC:SYS0:ML03:AO037.DESC') #x-ray_energy3
pv53 = epics.PV('SIOC:SYS0:ML03:AO053.DESC') #x-ray_energy4
pv5.put(xen1)
print pv5.get()
pv21.put(xen2)
print pv21.get()
pv37.put(xen3)
print pv37.get()
pv53.put(xen4)
print pv53.get()

pv6 = epics.PV('SIOC:SYS0:ML03:AO006.DESC') #x-ray_energy_priority1
pv22 = epics.PV('SIOC:SYS0:ML03:AO022.DESC') #x-ray_energy_priority2
pv38 = epics.PV('SIOC:SYS0:ML03:AO038.DESC') #x-ray_energy_priority3
pv54 = epics.PV('SIOC:SYS0:ML03:AO054.DESC') #x-ray_energy_priority4
pv6.put(xenp1)
print pv6.get()
pv22.put(xenp2)
print pv22.get()
pv38.put(xenp3)
print pv38.get()
pv54.put(xenp4)
print pv54.get()

pv7 = epics.PV('SIOC:SYS0:ML03:AO007.DESC') #bunch_length1
pv23 = epics.PV('SIOC:SYS0:ML03:AO023.DESC') #bunch_length2
pv39 = epics.PV('SIOC:SYS0:ML03:AO039.DESC') #bunch_length3
pv55 = epics.PV('SIOC:SYS0:ML03:AO055.DESC') #bunch_length4
pv7.put(bl1)
print pv7.get()
pv23.put(bl2)
print pv23.get()
pv39.put(bl3)
print pv39.get()
pv55.put(bl4)
print pv55.get()

pv8 = epics.PV('SIOC:SYS0:ML03:AO008.DESC') #bunch_length_priority1
pv24 = epics.PV('SIOC:SYS0:ML03:AO024.DESC') #bunch_length_priority2
pv40 = epics.PV('SIOC:SYS0:ML03:AO040.DESC') #bunch_length_priority3
pv56 = epics.PV('SIOC:SYS0:ML03:AO056.DESC') #bunch_length_priority4
pv8.put(blp1)
print pv8.get()
pv24.put(blp2)
print pv24.get()
pv40.put(blp3)
print pv40.get()
pv56.put(blp4)
print pv56.get()

pv9 = epics.PV('SIOC:SYS0:ML03:AO009.DESC') #minimum_FEL1
pv25 = epics.PV('SIOC:SYS0:ML03:AO025.DESC') #minimum_FEL2
pv41 = epics.PV('SIOC:SYS0:ML03:AO041.DESC') #minimum_FEL3
pv57 = epics.PV('SIOC:SYS0:ML03:AO057.DESC') #minimum_FEL4
pv9.put(mfel1)
print pv9.get()
pv25.put(mfel2)
print pv25.get()
pv41.put(mfel3)
print pv41.get()
pv57.put(mfel4)
print pv57.get()

pv10 = epics.PV('SIOC:SYS0:ML03:AO010.DESC') #minimum_FEL_priority1
pv26 = epics.PV('SIOC:SYS0:ML03:AO026.DESC') #minimum_FEL_priority2
pv42 = epics.PV('SIOC:SYS0:ML03:AO042.DESC') #minimum_FEL_priority3
pv58 = epics.PV('SIOC:SYS0:ML03:AO058.DESC') #minimum_FEL_priority4
pv10.put(mfelp1)
print pv10.get()
pv26.put(mfelp2)
print pv26.get()
pv42.put(mfelp3)
print pv42.get()
pv58.put(mfelp4)
print pv58.get()

pv11 = epics.PV('SIOC:SYS0:ML03:AO011.DESC') #charge1
pv27 = epics.PV('SIOC:SYS0:ML03:AO027.DESC') #charge2
pv43 = epics.PV('SIOC:SYS0:ML03:AO043.DESC') #charge3
pv59 = epics.PV('SIOC:SYS0:ML03:AO059.DESC') #charge4
pv11.put(chrg1)
print pv11.get()
pv27.put(chrg2)
print pv27.get()
pv43.put(chrg3)
print pv43.get()
pv59.put(chrg4)
print pv59.get()

pv12 = epics.PV('SIOC:SYS0:ML03:AO012.DESC') #charge_priority1
pv28 = epics.PV('SIOC:SYS0:ML03:AO028.DESC') #charge_priority2
pv44 = epics.PV('SIOC:SYS0:ML03:AO044.DESC') #charge_priority3
pv60 = epics.PV('SIOC:SYS0:ML03:AO060.DESC') #charge_priority4
pv12.put(chrgp1)
print pv12.get()
pv28.put(chrgp2)
print pv28.get()
pv44.put(chrgp3)
print pv44.get()
pv60.put(chrgp4)
print pv60.get()

pv13 = epics.PV('SIOC:SYS0:ML03:AO013.DESC') #band_width1
pv29 = epics.PV('SIOC:SYS0:ML03:AO029.DESC') #band_width2
pv45 = epics.PV('SIOC:SYS0:ML03:AO045.DESC') #band_width3
pv61 = epics.PV('SIOC:SYS0:ML03:AO061.DESC') #band_width4
pv13.put(bw1)
print pv13.get()
pv29.put(bw2)
print pv29.get()
pv45.put(bw3)
print pv45.get()
pv61.put(bw4)
print pv61.get()

pv14 = epics.PV('SIOC:SYS0:ML03:AO014.DESC') #band_width_priority1
pv30 = epics.PV('SIOC:SYS0:ML03:AO030.DESC') #band_width_priority2
pv46 = epics.PV('SIOC:SYS0:ML03:AO046.DESC') #band_width_priority3
pv62 = epics.PV('SIOC:SYS0:ML03:AO062.DESC') #band_width_priority4
pv14.put(bwp1)
print pv14.get()
pv30.put(bwp2)
print pv30.get()
pv46.put(bwp3)
print pv46.get()
pv62.put(bwp4)
print pv62.get()

pv15 = epics.PV('SIOC:SYS0:ML03:AO015.DESC') #pulse_rate1
pv31 = epics.PV('SIOC:SYS0:ML03:AO031.DESC') #pulse_rate2
pv47 = epics.PV('SIOC:SYS0:ML03:AO047.DESC') #pulse_rate3
pv63 = epics.PV('SIOC:SYS0:ML03:AO063.DESC') #pulse_rate4
pv15.put(pr1)
print pv15.get()
pv31.put(pr2)
print pv31.get()
pv47.put(pr3)
print pv47.get()
pv63.put(pr4)
print pv63.get()

pv16 = epics.PV('SIOC:SYS0:ML03:AO016.DESC') #pulse_rate_priority1
pv32 = epics.PV('SIOC:SYS0:ML03:AO032.DESC') #pulse_rate_priority2
pv48 = epics.PV('SIOC:SYS0:ML03:AO048.DESC') #pulse_rate_priority3
pv64 = epics.PV('SIOC:SYS0:ML03:AO064.DESC') #pulse_rate_priority4
pv16.put(prp1)
print pv16.get()
pv32.put(prp2)
print pv32.get()
pv48.put(prp3)
print pv48.get()
pv64.put(prp4)
print pv64.get()

time.sleep(.05)