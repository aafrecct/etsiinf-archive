metro_distances = {
    "Line 1" : [1537, 1733, 956, 1028, 2134, 1205, 2114, 1095, 887, 654, 1592, 1033, 1347, 1611, 1133, 1317, 1264],
    "Line 2" : [1188, 1246, 1737, 1425, 1223, 988, 1314, 1004, 1068, 1179, 865, 1221, 1072, 1526, 1457, 927, 1510],
    "Line 3" : [1538, 2678, 3177, 777, 1141, 1256, 1120, 1896, 3422, 807, 1351, 1283, 1135, 1224, 1055]
}

metro_network = {
  "Line 1": {
    "number": 1,
    "color": "red",
    "length": 22640,
    "transfers": {
      "Line 2": [120, 217],
      "Line 3": [119, 313]
    },
    "stations" : [
      {"name": "Akademmistechko", "ukranian_name": "Академмістечко", "coords": [1, 5]},
      {"name": "Zhytomyrska", "ukranian_name": "Житомирська", "coords": [3, 7]},
      {"name": "Sviatoshyn", "ukranian_name": "Святошин", "coords": [5, 9]},
      {"name": "Nyvky", "ukranian_name": "Нивки", "coords": [7, 11]},
      {"name": "Beresteiska", "ukranian_name": "Берестейська", "coords": [9, 13]},
      {"name": "Shuliavska", "ukranian_name": "Шулявська", "coords": [11, 15]},
      {"name": "Politekhnichnyi Instytut", "ukranian_name": "Політехнічний інститут", "coords": [13, 17]},
      {"name": "Vokzalna", "ukranian_name": "Вокзальна", "coords": [16, 17]},
      {"name": "Universytet", "ukranian_name": "Університет", "coords": [20, 17]},
      {"name": "Teatralna", "ukranian_name": "Театральна", "connects_with": "Zoloti vorota", "coords": [23, 17]},
      {"name": "Kreshchatyk", "ukranian_name": "Хрещатик", "connects_with": "Maidan Nezalezhnosti", "coords": [26, 17]},
      {"name": "Arsenalna", "ukranian_name": "Арсенальна", "coords": [28, 19]},
      {"name": "Dnipro", "ukranian_name": "Дніпро", "coords": [30, 21]},
      {"name": "Hidropark", "ukranian_name": "Гідропарк", "coords": [33, 21]},
      {"name": "Livoberezhna", "ukranian_name": "Лівобережна", "coords": [36, 21]},
      {"name": "Darnytsia", "ukranian_name": "Дарниця", "coords": [38, 19]},
      {"name": "Chernihivska", "ukranian_name": "Чернігівська", "coords": [40, 17]},
      {"name": "Lisova", "ukranian_name": "Лісова", "coords": [42, 15]}
    ]
  },
  "Line 2": {
    "number": 2,
    "color": "blue",
    "length": 20950,
    "transfers": {
      "Line 1": [217, 120],
      "Line 3": [218, 314]
    },
    "stations": [
      {"name": "Heroyiv Dnipra", "ukranian_name": "Героїв Дніпра", "coords": [24, 1]},
      {"name": "Minska", "ukranian_name": "Мінська", "coords": [24, 3]},
      {"name": "Obolon", "ukranian_name": "Оболонь", "coords": [24, 5]},
      {"name": "Pochaina", "ukranian_name": "Почайна", "coords": [24, 7]},
      {"name": "Tarasa Shevchenka", "ukranian_name": "Тараса Шевченка", "coords": [24, 9]},
      {"name": "Kontraktova ploshcha", "ukranian_name": "Контрактова площа", "coords": [24, 11]},
      {"name": "Poshtova ploshcha", "ukranian_name": "Поштова площа", "coords": [24, 13]},
      {"name": "Maidan Nezalezhnosti", "ukranian_name": "Майдан Незалежності", "connects_with":  "Kreshchatyk", "coords": [24, 15]},
      {"name": "Ploshcha Lva Tolstogo", "ukranian_name": "Площа Льва Толстого", "connects_with": "Palats Sportu", "coords": [22, 20]},
      {"name": "Olimpiiska", "ukranian_name": "Олімпійська", "coords": [20, 22]},
      {"name": "Palats Ukraina", "ukranian_name": "Палац «Україна»", "coords": [20, 24]},
      {"name": "Lybidska", "ukranian_name": "Либідська", "coords": [20, 26]},
      {"name": "Demiivska", "ukranian_name": "Деміївська", "coords": [18, 28]},
      {"name": "Holosiivska", "ukranian_name": "Голосіївська", "coords": [16, 30]},
      {"name": "Vasylkivska", "ukranian_name": "Васильківська", "coords": [14, 32]},
      {"name": "Vystavkovyi tsentr", "ukranian_name": "Виставковий центр", "coords": [12, 34]},
      {"name": "Ipodrom", "ukranian_name": "Іподром", "coords": [10, 36]},
      {"name": "Teremky", "ukranian_name": "Теремки", "coords":[7, 36]}
    ]
  },
  "Line 3": {
    "number": 3,
    "color": "green",
    "length": 23860,
    "transfers": {
      "Line 1": [313, 119],
      "Line 2": [314, 218]
    },
    "stations": [
      {"name": "Syrets", "ukranian_name": "Сирець", "coords": [15, 9]},
      {"name": "Dorohozhychi", "ukranian_name": "Дорогожичі", "coords": [17, 11]},
      {"name": "Lukianivska", "ukranian_name": "Лук'янівська", "coords": [19, 13]},
      {"name": "Zoloti vorota", "ukranian_name": "Золоті ворота", "connects_with": "Teatralna", "coords": [21, 15]},
      {"name": "Palats Sportu", "ukranian_name": "Палац спорту", "connects_with": "Ploshcha Lva Tolstogo", "coords": [24, 20]},
      {"name": "Klovska", "ukranian_name": "Кловська", "coords": [26, 22]},
      {"name": "Percherska", "ukranian_name": "Печерська", "coords": [26, 24]},
      {"name": "Druzhby Narodiv", "ukranian_name": "Дружби народів", "coords": [26, 26]},
      {"name": "Vydubychi", "ukranian_name": "Видубичі", "coords": [26, 28]},
      {"name": "Slavutych", "ukranian_name": "Славутич", "coords": [28, 30]},
      {"name": "Osokorky", "ukranian_name": "Осокорки", "coords": [30, 32]},
      {"name": "Pozniaky", "ukranian_name": "Позняки", "coords": [32, 34]},
      {"name": "Kharkivska", "ukranian_name": "Харківська", "coords": [35, 34]},
      {"name": "Vyrlytsia", "ukranian_name": "Вирлиця", "coords": [37, 32]},
      {"name": "Boryspilska", "ukranian_name": "Бориспільська", "coords": [39, 30]},
      {"name": "Chervonyi Khutir", "ukranian_name": "Червоний хутір", "coords": [41, 28]}
    ]
  }
}

symbolicmap = {
"lines": [
    [1, [1, 5], [3, 7]],
    [1, [3, 7], [5, 9]],
    [1, [5, 9], [7, 11]],
    [1, [7, 11], [9, 13]],
    [1, [9, 13], [11, 15]],
    [1, [11, 15], [13, 17]],
    [1, [13, 17], [16, 17]],
    [1, [16, 17], [20, 17]],
    [1, [20, 17], [23, 17]],
    [1, [23, 17], [26, 17]],
    [1, [26, 17], [28, 19]],
    [1, [28, 19], [30, 21]],
    [1, [30, 21], [33, 21]],
    [1, [33, 21], [36, 21]],
    [1, [36, 21], [38, 19]],
    [1, [38, 19], [40, 17]],
    [1, [40, 17], [42, 15]],
    [2, [24, 1], [24, 3]],
    [2, [24, 3], [24, 5]],
    [2, [24, 5], [24, 7]],
    [2, [24, 7], [24, 9]],
    [2, [24, 9], [24, 11]],
    [2, [24, 11], [24, 13]],
    [2, [24, 13], [24, 15]],
    [2, [24, 15], [24, 18], [22, 20]],
    [2, [22, 20], [20, 22]],
    [2, [20, 22], [20, 24]],
    [2, [20, 24], [20, 26]],
    [2, [20, 26], [18, 28]],
    [2, [18, 28], [16, 30]],
    [2, [16, 30], [14, 32]],
    [2, [14, 32], [12, 34]],
    [2, [12, 34], [10, 36]],
    [2, [10, 36], [7, 36]],
    [3, [15, 9], [17, 11]],
    [3, [17, 11], [19, 13]],
    [3, [19, 13], [21, 15]],
    [3, [21, 15], [21, 17], [24, 20]],
    [3, [24, 20], [26, 22]],
    [3, [26, 22], [26, 24]],
    [3, [26, 24], [26, 26]],
    [3, [26, 26], [26, 28]],
    [3, [26, 28], [28, 30]],
    [3, [28, 30], [30, 32]],
    [3, [30, 32], [32, 34]],
    [3, [32, 34], [35, 34]],
    [3, [35, 34], [37, 32]],
    [3, [37, 32], [39, 30]],
    [3, [39, 30], [41, 28]],
    [0, [24, 15], [26, 17]],
    [0, [21, 15], [23, 17]],
    [0, [24, 20], [22, 20]]
]}
