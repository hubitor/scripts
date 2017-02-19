#!/bin/env python3
from datetime import time, date, datetime, timedelta
from pprint import pprint
import operator
import sys

MATERIALS = ["OCL", "XML", "Test.F"]
TYPES = ["C", "TP", "TD"]
REPEATS = ["Weekly", "Bi-Weekly", "Monthly"]
DAYS = ["Mo", "Tu", "We", "Th", "Fr", "Sa"]
C_WIDTH = 2
C_HEIGHT = 2

UNCOLOR = '\033[m'
NO_COLOR = ''
BG_GREEN = '\033[32;3m'
BG_ORANGE = '\033[33;3m'
BG_BLUE = '\033[34;3m'
BG_MOVE = '\033[35;3m'

try:
    C_WIDTH = int(sys.argv[1])
except:
    pass
try:
    C_HEIGHT = int(sys.argv[2])
except:
    pass

class Material:

    def __init__(self, name, type, salle, start, end=None, repeat="Weekly"):
        assert name in MATERIALS
        assert type in TYPES
        assert repeat in REPEATS
        assert 8.15 <= start <= 16.30
        assert end is None or 8.45 <= end <= 18.00
        assert salle and isinstance(salle, str)
        self.name = name
        self.type = type
        self.salle = salle
        self.repeat = repeat
        self.start = time(int(start), int(start * 100 % 100))
        if end:
            self.end = time(int(end), int(end * 100 % 100))
        else:
            self.end = (datetime(1, 1, 1, self.start.hour, self.start.minute) +
                        timedelta(hours=1, minutes=30)).time()
        self.duration = round((self.end.hour - self.start.hour) * 4 -
                              self.start.minute // 15 +
                              self.end.minute // 15)
        assert 6 <= self.duration <= 6
        self.start_i = round((self.start.hour - 8) *
                             4 + self.start.minute / 15) * C_WIDTH
        self.end_i = self.start_i + (self.duration * C_WIDTH)

    def __str__(self):
        return "{0.name:12}  {0.type:2}  {0.start:%H:%M}  {0.end:%H:%M}  "\
            "{0.repeat}".format(self)


emploit = {
    "Mo": [
        Material("OCL", "TD", "Lab Info 2", 10.00),
        Material("XML", "C", "A2", 13.15, 16.15)],
    "Tu": [
        Material("OCL", "C", "Lab Info 2", 13.15, 16.15)],
    "Fr": [
        Material("Test.F", "C", "P021", 10.00),
        Material("XML", "TD", "Lab Info 3", 14.00)],
    "Sa": [
        Material("Test.F", "TD", "1208", 10.30)],
}

timeline_txt = []
timeline_color = []
for index, day in enumerate(DAYS):
    tl_txt = []
    tl_color = []
    materials = filter(lambda m: type(m) in (Material, list),
                       emploit.get(day, []))
    materials = map(lambda m: m if type(m) == Material else m[0], materials)
    materials = sorted(materials, key=operator.attrgetter("start"))
    i = 0
    for material in materials:
        tl_txt.append(' ' * (material.start_i - i))
        tl_color.append(NO_COLOR)
        txt = material.name.center(material.duration * C_WIDTH, ' ')
        tl_txt.append(txt)
        if material.type == "C":
            tl_color.append(BG_GREEN)
        elif material.type == "TD":
            tl_color.append(BG_ORANGE)
        elif material.type == "TP":
            tl_color.append(BG_BLUE)
        i = material.end_i
    timeline_txt.append(tl_txt)
    timeline_color.append(tl_color)

print('\033[32;3m', 'Cours ', '\033[m',
      '\033[33;3m', '  TD  ', '\033[m',
      '\033[34;3m', '  TP  ', '\033[m', '\n')

print('___|', end='')
for i in range(8, 18):
    t = str(i).center(4 * C_WIDTH)
    if i % 2:
        t = '\033[;3m\033[36;4m' + t + '\033[m'
    else:
        t = '\033[;3m\033[37;4m' + t + '\033[m'
    print(t, end='')
print()

for i, day in enumerate(DAYS):
    l_txt = ''.join(color + txt + UNCOLOR
                    for color, txt in zip(timeline_color[i], timeline_txt[i]))
    l_empt = ''.join(color + ' ' * len(txt) + UNCOLOR
                     for color, txt in zip(timeline_color[i], timeline_txt[i]))
    l_line = ''.join('\033[;4m' + color + ' ' * len(txt) + UNCOLOR
                     for color, txt in zip(timeline_color[i], timeline_txt[i]))
    for i in range(int((C_HEIGHT - 1) / 2)):
        print('   |', l_empt, sep='')
    print(day, ' |', l_txt, sep='')
    for i in range(int(C_HEIGHT / 2) - 1):
        print('   |', l_empt, sep='')
    print('\033[;4m', '   |', l_line, sep='')
