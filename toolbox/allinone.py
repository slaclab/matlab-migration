#!/usr/local/lcls/package/python/current/bin/python

import sys, os, random
from PyQt4 import QtGui, QtCore
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from epics import *
from datetime import datetime
import matplotlib
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
from mpl_toolkits.axes_grid1 import ImageGrid
from xml.etree import ElementTree
from re import sub
from shutil import copy
from time import sleep
import numpy as np
import scipy.ndimage as snd

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent=None)
        self.setWindowTitle('IrisssSteering')
        self.create_main_frame()
        self.create_status_bar()
        self.abort = False
        self.bdmult=1
        self.bdmult2=1
       
    def on_draw(self):
        self.abort = False
        self.statusBar().showMessage('Running')
        self.statusBar().setStyleSheet('QStatusBar{background-color:black;color:white;font:12pt;font:bold}')
        self.axes.clear()
        self.axes.set_position([0.05, 0.1, 0.4, 0.75])
        self.axes.set_ylim([190,320])
        self.axes.set_xlim([270,410])
        for t in self.axes.xaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes.xaxis.get_ticklabels():
            t.set_color('gray')
        for t in self.axes.yaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes.yaxis.get_ticklabels():
            t.set_color('gray')
        self.axes2.clear()
        self.axes2.set_position([0.55, 0.1, 0.4, 0.75])
        self.axes2.set_xlim([0,110])
        self.axes2.set_ylim([0,95])
        for t in self.axes2.xaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes2.xaxis.get_ticklabels():
            t.set_color('gray')
        for t in self.axes2.yaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes2.yaxis.get_ticklabels():
            t.set_color('gray')
            QApplication.processEvents()
            image=caget('CAMR:IN20:186:IMAGE')
            image.shape=(480,640)
            image = np.flipud(image)
            image2=caget('CAMR:LR20:119:Image:ArrayData')
            x=caget('CAMR:LR20:119:SizeX_RBV')
            y=caget('CAMR:LR20:119:SizeY_RBV')
            pixcount=x*y
            image2=image2[0:pixcount]
            image2 = np.flipud(image2)
            image2.shape=(y,x)
        QApplication.processEvents()
        if self.centroid_cb.isChecked():
            self.Centroid_CB()
        image[:]=[x*self.bdmult for x in image]
        image2[:] = [x*self.bdmult2 for x in image2]
        plotyo=self.axes.imshow(image)
        plotyo2=self.axes2.imshow(image2)
        while self.abort==False:
            self.axes.set_position([0.05, 0.1, 0.4, 0.75])
            self.axes2.set_position([0.55, 0.1, 0.4, 0.75])
            self.axes2.set_title('C-IRIS',color = 'gray')
            self.axes.set_title('VCC',color = 'gray')
            QApplication.processEvents()
            image=caget('CAMR:IN20:186:IMAGE')
            image.shape=(480,640)
            image = np.flipud(image)
            QApplication.processEvents()
            image2=caget('CAMR:LR20:119:Image:ArrayData')
            x=caget('CAMR:LR20:119:SizeX_RBV')
            y=caget('CAMR:LR20:119:SizeY_RBV')
            pixcount=x*y
            image2=image2[0:pixcount]
            image2.shape=(y,x)
            fel=caget('GDET:FEE1:241:ENRC')
            self.FELnum.setText(str(round(fel,2)))
            QApplication.processEvents()
            image2 = np.flipud(image2)
            image=image*self.bdmult
            image2=image2*self.bdmult2
            if self.centroid_cb.isChecked():
                QApplication.processEvents()
                xcent,ycent=self.CalcCentroid(image)
                self.centroidyo.set_xdata(xcent)
                self.centroidyo.set_ydata(ycent)
                xcent2,ycent2=self.CalcCentroid2(image2)
                self.centroidyo2.set_xdata(xcent2)
                self.centroidyo2.set_ydata(ycent2)
                plotyo.set_data(image)
                plotyo2.set_data(image2)
                self.canvas.draw()
                self.vxcentc.setText(str(round(xcent,2)))
                self.vycentc.setText(str(round(ycent,2)))
                self.cxcentc.setText(str(round(xcent2,2)))
                self.cycentc.setText(str(round(ycent2,2)))
                
            else:
                plotyo.set_data(image)
                plotyo2.set_data(image2)
                self.canvas.draw()

    def create_main_frame(self):
        self.main_frame = QWidget()
        self.dpi = 125
        self.fig = Figure((7.5, 3.0), dpi=self.dpi)
        self.fig.set_edgecolor('blue')
        self.fig.suptitle('IrisssSteer')
        self.canvas = FigureCanvas(self.fig)
        self.fig.patch.set_facecolor('black')
        self.canvas.setParent(self.main_frame)
        self.main_frame.setStyleSheet('QWidget{background-color:black}')
        self.axes = self.fig.add_subplot(111)
        self.axes.set_position([0.05, 0.1, 0.4, 0.75])
        for t in self.axes.xaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes.xaxis.get_ticklabels():
            t.set_color('green')
        for t in self.axes.yaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes.yaxis.get_ticklabels():
            t.set_color('green')
        self.axes2 = self.fig.add_subplot(121)
        self.axes2.set_position([0.55, 0.1, 0.4, 0.75])
        for t in self.axes2.xaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes2.xaxis.get_ticklabels():
            t.set_color('green')
        for t in self.axes2.yaxis.get_ticklines():
            t.set_color('white')
        for t in self.axes2.yaxis.get_ticklabels():
            t.set_color('green')
        self.feed = caget('LASR:LR20:110:POS_FDBK')
        if self.feed == 1:
            self.feedrb = QLabel('Loop Closed')
        else:
            self.feedrb = QLabel('Loop Open')
        self.centroid_cb = QCheckBox("Calc. Centroid")
        self.centroid_cb.setChecked(False)
        palette = QPalette()
        brush = QBrush(QColor(255, 255, 255))
        brush.setStyle(Qt.SolidPattern)
        palette.setBrush(QPalette.Shadow, brush)
        self.centroid_cb.setPalette(palette)
        palette.setColor(QPalette.Background,Qt.white)
        self.centroid_cb.clicked.connect(self.Centroid_CB)
        self.FEL = QLabel('FEL =')
        self.FEL.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.FELnum = QLabel()
        self.FELnum.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.centroid_cb.setStyleSheet('QCheckBox{background-color:black;color:white;font:12pt;font:bold}')
        self.feedset = QLabel('Feedback Status:')
        self.feedset.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.feedrb.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        self.draw_button = QPushButton("&Start")
        self.draw_button.setStyleSheet('QPushButton{background-color:green;color:white;font:14pt;font:bold}')
        self.connect(self.draw_button, SIGNAL('clicked()'), self.on_draw)
        self.stop_button = QPushButton("&Stop")
        self.connect(self.stop_button, SIGNAL('clicked()'), self.stop)
        self.stop_button.setStyleSheet('QPushButton{background-color:red;color:white;font:14pt;font:bold}')
        self.upM18h_button = QPushButton("Right")
        self.upM18h_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.connect(self.upM18h_button,SIGNAL('clicked()'),self.up_M18h)
        self.downM18h_button = QPushButton("Left")
        self.connect(self.downM18h_button,SIGNAL('clicked()'),self.down_M18h)
        self.downM18h_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.upM18v_button = QPushButton("Up")
        self.connect(self.upM18h_button,SIGNAL('clicked()'),self.down_M18v)
        self.upM18v_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.downM18v_button = QPushButton("Down")
        self.connect(self.downM18h_button,SIGNAL('clicked()'),self.down_M18h)
        self.downM18v_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.openfeedb = QPushButton("Open FB")
        self.connect(self.openfeedb,SIGNAL('clicked()'),self.openfeed)
        self.openfeedb.setStyleSheet('QPushButton{background-color:blue;color:white;font:10pt;font:bold}')
        self.closefeedb = QPushButton("Close FB")
        self.connect(self.closefeedb,SIGNAL('clicked()'),self.closefeed)
        self.closefeedb.setStyleSheet('QPushButton{background-color:blue;color:white;font:10pt;font:bold}')
        self.setfeedb = QPushButton("Set Ref")
        self.connect(self.setfeedb,SIGNAL('clicked()'),self.setfeed)
        self.setfeedb.setStyleSheet('QPushButton{background-color:blue;color:white;font:10pt;font:bold}')
        self.logb = QPushButton("Log")
        self.connect(self.logb,SIGNAL('clicked()'),self.logbook)
        self.logb.setStyleSheet('QPushButton{background-color:pink;color:green;font:12pt;font:bold}')
        self.M18pos=QLabel('M18 Horizontal = '+str(round(caget('MIRR:LR20:113:M18_MOTR_H'),3)))
        self.M18pos.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M18vpos = QLabel('M18 Vertical = '+str(round(caget('MIRR:LR20:113:M18_MOTR_V'),3))) 
        self.M18vpos.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M18 = QLabel('M18 Positions')
        self.M18.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M17 = QLabel('M17 Positions')
        self.M17.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M18t = QLabel('M18')
        self.M18t.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M17t = QLabel('M17')
        self.M17t.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')

        self.getref_button = QPushButton("Get Ref")
        self.connect(self.getref_button,SIGNAL('clicked()'),self.getref)
        self.getref_button.setStyleSheet('QPushButton{background-color:blue;color:white;font:10pt;font:bold}')
        
        self.upM17h_button = QPushButton("Right")
        self.connect(self.upM17h_button,SIGNAL('clicked()'),self.up_M17h)
        self.upM17h_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.downM17h_button = QPushButton("Left")
        self.connect(self.downM17h_button,SIGNAL('clicked()'),self.down_M17h)
        self.downM17h_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.upM17v_button = QPushButton("Down")
        self.connect(self.upM17v_button,SIGNAL('clicked()'),self.up_M17v)
        self.upM17v_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.downM17v_button = QPushButton("Up")
        self.connect(self.downM17v_button,SIGNAL('clicked()'),self.down_M17v)
        self.downM17v_button.setStyleSheet('QPushButton{background-color:orange;color:blue;font:12pt;font:bold}')
        self.M17pos=QLabel('M17 Horizontal = '+str(round(caget('MIRR:LR20:114:M17_MOTR_H'),3)))
        self.M17pos.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.M17vpos = QLabel('M17 Vertical = '+str(round(caget('MIRR:LR20:114:M17_MOTR_V'),3)))
        self.M17vpos.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.slider = QScrollBar(Qt.Horizontal)
        self.slider.setRange(1, 15)
        self.slider.setValue(8)
        self.slider.setTracking(True)
        self.slider.setStyleSheet('QScrollBar{background-color:gray;color:cyan};QScrollBar.handle{background-color:white}')
        self.slider2 = QScrollBar(Qt.Horizontal)
        self.slider2.setRange(1, 15)
        self.slider2.setValue(8)
        self.slider2.setTracking(True)
        self.slider2.setStyleSheet('QScrollBar{background-color:gray;color:cyan};QScrollBar.handle{background-color:white}') 
        self.connect(self.slider, SIGNAL('valueChanged(int)'), self.changebd)
        self.connect(self.slider2,SIGNAL('valueChanged(int)'),self.changebd2)
        self.VCCbd = QLabel('VCC Bit Depth')
        self.CIRISbd=QLabel('C-IRIS Bit Depth')
        self.vxcent= QLabel('VCC X')
        self.vycent = QLabel('VCC Y')
        self.cxcent= QLabel('CIRIS X')
        self.cycent = QLabel('CIRIS Y')
        self.vxcent.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.vycent.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}') 
        self.cxcent.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.cycent.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.vxcentc= QLabel('VCC X')
        self.vycentc = QLabel('VCC Y')
        self.cxcentc= QLabel('CIRIS X')
        self.cycentc = QLabel('CIRIS Y')
        self.vxcentc.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.vycentc.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}') 
        self.cxcentc.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.cycentc.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.VCCref= QLabel('VCC Ref')
        self.CIRISref = QLabel('IRIS Ref')
        self.VCCref.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.CIRISref.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.VCCcur= QLabel('VCC Cur')
        self.CIRIScur = QLabel('IRIS Cur')
        self.VCCcur.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.CIRIScur.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')
        self.VCCbd.setStyleSheet('QLabel{background-color:black;color:white;font:12pt,font:bold}')
        self.CIRISbd.setStyleSheet('QLabel{background-color:black;color:white;font:10pt;font:bold}')
        grid = QGridLayout()
        vbox = QVBoxLayout()
        vbox.addWidget(self.canvas)
        M18frame = QGroupBox()
        M18frame.setStyleSheet('QGroupBox{background-color:black;color:white;font:bold;font:12}')#_fromUtf8("color: rgb(170, 255, 255)"))
        M18frame.setTitle('Controls and Positions')
        M18frame.setPalette(palette)
        M19frame = QGroupBox()
        M19frame.setTitle('Feedbacks and Centroid Reference')
        M19frame.setStyleSheet('QGroupBox{background-color:black;color:white;font:bold;font:12}')
        M19frame.setPalette(palette)
        M10frame = QGroupBox()
        M10frame.setTitle('Centroid Reference and Current Positions Pixelmap(X,Y)')
        M10frame.setStyleSheet('QGroupBox{background-color:black;color:white;font:bold;font:12}')
        M10frame.setPalette(palette)
        vbox.addLayout(grid)
        grid.setSpacing(15)
        grid.addWidget(self.mpl_toolbar, 1,4,1,2, Qt.AlignHCenter)
        self.mpl_toolbar.setStyleSheet('QWidget{background-color:black;color:white}')
        grid.addWidget(self.slider, 2,3,1,2)#, Qt.AlignHCenter)
        grid.addWidget(self.slider2,2,5,1,2)
        grid.addWidget(self.logb,1,8)
        grid.addWidget(M18frame,3,0,5,10)
        grid.addWidget(M19frame,7,0,4,10)
        grid.addWidget(M10frame,10,0,5,10)
        grid.addWidget(self.centroid_cb,9,7,1,2)
        grid.addWidget(self.feedrb, 9,5, Qt.AlignLeft)
        grid.addWidget(self.feedset, 9,4, Qt.AlignRight)
        grid.addWidget(self.openfeedb, 9,1)
        grid.addWidget(self.vxcent, 11,2)
        grid.addWidget(self.vycent,11,3)
        grid.addWidget(self.cxcent,11,7)
        grid.addWidget(self.cycent,11,8)
        grid.addWidget(self.VCCref,11,1)
        grid.addWidget(self.CIRISref,11,6)
        grid.addWidget(self.FEL,1,6)
        grid.addWidget(self.FELnum,1,7)
        grid.addWidget(self.VCCcur,12,1)
        grid.addWidget(self.CIRIScur,12,6)
        grid.addWidget(self.vxcentc, 12,2)
        grid.addWidget(self.vycentc,12,3)
        grid.addWidget(self.cxcentc,12,7)
        grid.addWidget(self.cycentc,12,8)
        grid.addWidget(self.closefeedb, 9, 3)
        grid.addWidget(self.setfeedb, 9,2)
        grid.addWidget(self.stop_button, 1,2)
        grid.addWidget(self.draw_button, 1,1)
        grid.addWidget(self.VCCbd, 2,1,1,2, Qt.AlignHCenter)
        grid.addWidget(self.CIRISbd, 2,7,1,2, Qt.AlignHCenter)
        grid.addWidget(self.M18,4,4, Qt.AlignHCenter)
        grid.addWidget(self.M17,4, 5, Qt.AlignHCenter)
        grid.addWidget(self.upM18h_button, 5,3)
        grid.addWidget(self.downM18h_button, 5,1)
        grid.addWidget(self.M18pos, 5,4, Qt.AlignHCenter)
        grid.addWidget(self.upM18v_button, 4,2)
        grid.addWidget(self.downM18v_button, 6,2)
        grid.addWidget(self.M18vpos, 6,4, Qt.AlignHCenter)
        grid.addWidget(self.upM17h_button,5,8)
        grid.addWidget(self.downM17h_button,5,6)
        grid.addWidget(self.M17pos,5,5, Qt.AlignHCenter)
        grid.addWidget(self.upM17v_button,6,7)
        grid.addWidget(self.downM17v_button,4,7)
        grid.addWidget(self.getref_button,9,6)
        grid.addWidget(self.M17vpos,6,5,Qt.AlignHCenter)
        grid.addWidget(self.M17t, 5,7, Qt.AlignHCenter)
        grid.addWidget(self.M18t, 5, 2, Qt.AlignHCenter)
        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)

    def getref(self):
        QApplication.processEvents()
        image=caget('CAMR:IN20:186:IMAGE')
        image.shape=(480,640)
        image = np.flipud(image)
        image2=caget('CAMR:LR20:119:Image:ArrayData')
        x=caget('CAMR:LR20:119:SizeX_RBV')
        y=caget('CAMR:LR20:119:SizeY_RBV')
        pixcount=x*y
        image2=image2[0:pixcount]
        image2 = np.flipud(image2)
        image2.shape=(y,x)
        self.Centroid_CB()
        xcent2,ycent2=self.CalcCentroid2(image2)
        xcent,ycent=self.CalcCentroid(image)
        self.vxcent.setText(str(round(xcent,2)))
        self.vycent.setText(str(round(ycent,2)))
        self.cxcent.setText(str(round(xcent2,2)))
        self.cycent.setText(str(round(ycent2,2)))
        

    def openfeed(self):
        caput('LASR:LR20:110:POS_FDBK', 0)
        self.feedrb.setText('Loop Open')

    def closefeed(self):
        caput('LASR:LR20:110:POS_FDBK', 1)
        self.feedrb.setText('Loop Closed')

    def setfeed(self):
        caput('LASR:LR20:110:SET_REF', 1)

    def changebd(self):
        slidervalue=self.slider.value()
        if slidervalue==8:
            self.bdmult=1
        else:
            self.bdmult=1.0+((slidervalue-8)/10.0)

    def CalcCentroid(self,image):
        import scipy.ndimage as snd
        threshold=image.mean() + 3*image.std()
        centers = snd.center_of_mass(image > threshold)
        ycent=centers[0]
        xcent=centers[1]
        return xcent,ycent

    def Centroid_CB(self):
        if self.centroid_cb.isChecked():
            ycenter=0
            xcenter=0
            self.centroidyo,=self.axes.plot(xcenter,ycenter,markersize=80,c='black',marker='x')
            self.centroidyo2,=self.axes2.plot(xcenter,ycenter,markersize=80,c='black',marker='x')
        else:
            try:
                self.centroidyo.remove()
                #self.ui.centroidlabel.setText('')
                self.centroidyo2.remove()
                #self.ui.centroidlabel2.setText('')
            except AttributeError:
                return

    def CalcCentroid2(self,image2):
        import scipy.ndimage as snd
        threshold=image2.mean() + 3*image2.std()
        centers = snd.center_of_mass(image2 > threshold)
        ycent2=centers[0]
        xcent2=centers[1]
        return xcent2,ycent2
   
    def changebd2(self):
        slidervalue=self.slider2.value()
        if slidervalue==8:
            self.bdmult2=1
        else:
            self.bdmult2=1.0+((slidervalue-8)/10.0)
    
    def up_M18h(self):
        current = caget('MIRR:LR20:113:M18_MOTR_H')
        new = current + 0.001
        caput('MIRR:LR20:113:M18_MOTR_H', new)
        self.statusBar().showMessage('M18H up by 0.001 mm')
        self.M18pos.setText('M18 Horizontal = '+str(round(caget('MIRR:LR20:113:M18_MOTR_H'),3)))

    def down_M18h(self):
        current = caget('MIRR:LR20:113:M18_MOTR_H')
        new = current - 0.001
        caput('MIRR:LR20:113:M18_MOTR_H', new)
        self.statusBar().showMessage('M18H down by 0.001 mm')
        self.M18pos.setText('M18 Horizontal = '+str(round(caget('MIRR:LR20:113:M18_MOTR_H'),3)))

    def up_M18v(self):
        current = caget('MIRR:LR20:113:M18_MOTR_V')
        new = current + 0.001
        caput('MIRR:LR20:113:M18_MOTR_V', new)
        self.statusBar().showMessage('M18V up by 0.001 mm')
        self.M18vpos.setText('M18 Vertical = '+str(round(caget('MIRR:LR20:113:M18_MOTR_V'),3)))

    def down_M18v(self):
        current = caget('MIRR:LR20:113:M18_MOTR_V')
        new = current - 0.001
        caput('MIRR:LR20:113:M18_MOTR_V', new)
        self.statusBar().showMessage('M18V down by 0.001 mm')
        self.M18vpos.setText('M18 Vertical = '+str(round(caget('MIRR:LR20:113:M18_MOTR_V'),3)))

    def up_M17h(self):
        current = caget('MIRR:LR20:114:M17_MOTR_H')
        new = current + 0.001
        caput('MIRR:LR20:114:M17_MOTR_H', new)
        self.statusBar().showMessage('M18H up by 0.001 mm')
        self.M17pos.setText('M17 Horizontal = '+str(round(caget('MIRR:LR20:114:M17_MOTR_H'),3)))

    def down_M17h(self):
        current = caget('MIRR:LR20:114:M17_MOTR_H')
        new = current - 0.001
        caput('MIRR:LR20:114:M17_MOTR_H', new)
        self.statusBar().showMessage('M17H down by 0.001 mm')
        self.M17pos.setText('M17 Horizontal = '+str(round(caget('MIRR:LR20:114:M17_MOTR_H'),3)))

    def up_M17v(self):
        current = caget('MIRR:LR20:114:M17_MOTR_V')
        new = current + 0.001
        caput('MIRR:LR20:114:M17_MOTR_V', new)
        self.statusBar().showMessage('M17V up by 0.001 mm')
        self.M17vpos.setText('M17 Vertical = '+str(round(caget('MIRR:LR20:114:M17_MOTR_V'),3)))

    def down_M17v(self):
        current = caget('MIRR:LR20:114:M17_MOTR_V')
        new = current - 0.001
        caput('MIRR:LR20:114:M17_MOTR_V', new)
        self.statusBar().showMessage('M17V down by 0.001 mm')
        self.M17vpos.setText('M17 Vertical = '+str(round(caget('MIRR:LR20:114:M17_MOTR_V'),3)))
    
    def create_status_bar(self):
        self.status_text = QLabel("Iris Steer Initialized")
        self.statusBar().addWidget(self.status_text, 1)
        self.statusBar().setStyleSheet('QStatusBar{background-color:black;color:white;font:12pt;font:bold}')
        self.status_text.setStyleSheet('QLabel{background-color:black;color:white;font:12pt;font:bold}')

    def create_menu(self):        
        self.file_menu = self.menuBar().addMenu("&File")
        
        load_file_action = self.create_action("&Save plot",
            shortcut="Ctrl+S", slot=self.save_plot, 
            tip="Save the plot")
        quit_action = self.create_action("&Quit", slot=self.close, 
            shortcut="Ctrl+Q", tip="Close the application")
        
        self.add_actions(self.file_menu, 
            (load_file_action, None, quit_action))
        
        self.help_menu = self.menuBar().addMenu("&Help")
        about_action = self.create_action("&About", 
            shortcut='F1', slot=self.on_about, 
            tip='About')
        
        self.add_actions(self.help_menu, (about_action,))

    def save_plot(self):
        file_choices = "PNG (*.png)|*.png"
        
        path = unicode(QFileDialog.getSaveFileName(self, 
                        'Save file', '', 
                        file_choices))
        if path:
            self.canvas.print_figure(path, dpi=self.dpi)
            self.statusBar().showMessage('Saved to %s' % path, 2000)

    def logbook(self):
        curr_time = datetime.now()
        timeString = curr_time.strftime("%Y-%m-%dT%H:%M:%S")
        log_entry = ElementTree.Element(None)
        severity  = ElementTree.SubElement(log_entry, 'severity')
        location  = ElementTree.SubElement(log_entry, 'location')
        keywords  = ElementTree.SubElement(log_entry, 'keywords')
        time      = ElementTree.SubElement(log_entry, 'time')
        isodate   = ElementTree.SubElement(log_entry, 'isodate')
        log_user  = ElementTree.SubElement(log_entry, 'author')
        category  = ElementTree.SubElement(log_entry, 'category')
        title     = ElementTree.SubElement(log_entry, 'title')
        metainfo  = ElementTree.SubElement(log_entry, 'metainfo')
        imageFile = ElementTree.SubElement(log_entry, 'link')
        imageFile.text = timeString + '-00.ps'
        thumbnail = ElementTree.SubElement(log_entry, 'file')
        thumbnail.text = timeString + "-00.png"
        text      = ElementTree.SubElement(log_entry, 'text')
        log_entry.attrib['type'] = "LOGENTRY"
        category.text = "USERLOG"
        location.text = "not set"
        severity.text = "NONE"
        keywords.text = "none"
        time.text = curr_time.strftime("%H:%M:%S")
        isodate.text =  curr_time.strftime("%Y-%m-%d")
        metainfo.text = timeString + "-00.xml"
        fileName = "/tmp/" + metainfo.text
        fileName=fileName.rstrip(".xml")
        log_user.text = 'Iris Steering GUI'
        title.text = unicode('VCC and CIRIS')
        text.text = "New Positions (pixel location)"
        if text.text == "": text.text = " " # If field is truly empty, ElementTree leaves off tag entirely which causes logbook parser to fail
        xmlFile = open(fileName+'.xml',"w")
        rawString = ElementTree.tostring(log_entry, 'utf-8')
        parsedString = sub(r'(?=<[^/].*>)','\n',rawString) # Adds newline after each closing tag
        xmlString=parsedString[1:]
        xmlFile.write(xmlString)
        xmlFile.write("\n")  # Close with newline so cron job parses correctly
        xmlFile.close()
        self.canvas.print_figure(fileName+'.ps', dpi=self.dpi)
        self.canvas.print_figure(fileName+'.png',dpi=58)
        path = "/u1/lcls/physics/logbook/data/"
        copy(fileName+'.ps', path)
        copy(fileName+'.png', path)
        copy(fileName+'.xml', path)
        self.statusBar().showMessage('Sent to LCLS Physics Logbook!', 10000)

    def add_actions(self, target, actions):
        for action in actions:
            if action is None:
                target.addSeparator()
            else:
                target.addAction(action)

    def create_action(  self, text, slot=None, shortcut=None, 
                        icon=None, tip=None, checkable=False, 
                        signal="triggered()"):
        action = QAction(text, self)
        if icon is not None:
            action.setIcon(QIcon(":/%s.png" % icon))
        if shortcut is not None:
            action.setShortcut(shortcut)
        if tip is not None:
            action.setToolTip(tip)
            action.setStatusTip(tip)
        if slot is not None:
            self.connect(action, SIGNAL(signal), slot)
        if checkable:
            action.setCheckable(True)
        return action

    def on_about(self):
        msg = """Come on, meow."""
        QMessageBox.about(self, "About", msg.strip())

    def stop(self):
        self.statusBar().showMessage('Stopped')
        self.abort=True

def main():
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
