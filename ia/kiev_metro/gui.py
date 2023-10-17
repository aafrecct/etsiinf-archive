from pathlib import Path
from json import load
from tkinter import Tk, Canvas, Label, Menubutton, Menu, EventType, StringVar
from functools import partial
from kiev_metro.metro import Station, Line
from kiev_metro.search import short_path
from kiev_metro.data import symbolicmap

COLORMODE = "light"
OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")

window = Tk()

# Options!
screen_width, screen_height = window.winfo_screenwidth(), window.winfo_screenheight()
# screen_width, screen_height = 1920, 1080
map_scale = {480: 8, 720: 10, 768: 15, 1080: 22}[screen_height]
gaps = (screen_height // 80, screen_height // 60, screen_height // 40)
grid = {
    'x': [i * (screen_width / 20) for i in range(21)],
    'y': [i * (screen_height / 20) for i in range(21)]
}
fonts = {
    'title': ("Comfortaa Semibold", -40),
    'text': ("Comfortaa Medium", -20),
    'input': ("Comfortaa Medium", -16),
    'button': ("Comfortaa Bold", -80),
    'label': ("Comfortaa Medium", -38)
}
colors_dark = {
    'bg': '#1A1D20',
    'title': '#EEEEEE',
    'panel': ['#282828', '#303030', '#383838'],
    'button': ["", ""],
    'text': '#DDDDDD',
    'credits': '#333a59',
    'input': '#E4E4E4',
    'debugred': '#FF0000',
    'debugblue': '#0000FF',
    'lines': ['#e70b46', '#3c7fee', '#1eac56F', '#c1dfd8'],
    'lines_i': ['#e199ad', '#b2c4e1', '#a5d8b9', '#c1dfd8']
}
colors_light = {
    'bg': '#f6f8ff',
    'title': '#EEEEEE',
    'panel': ['#5c69a3', '#6673ab', '#7c89bf'],
    'button': ["#3c7fee", "#2e6be6"],
    'text': '#DDDDDD',
    'credits': '#333a59',
    'input': '#333a59',
    'inputbg': ['#c1dfd8', '#98cabe'],
    'debugred': '#FF0000',
    'debugblue': '#0000FF',
    'lines': ['#e70b46', '#3c7fee', '#1eac56', '#c1dfd8'],
    'lines_i': ['#e199ad', '#b2c4e1', '#a5d8b9', '#7c89bf']
}
colors = colors_dark if COLORMODE == 'dark' else colors_light

# Main Window!
window.geometry("1280x720")
window.configure(bg=colors['bg'])

# Main Canvas!
bgcanvas = Canvas(
    window,
    bg=colors['bg'],
    height=720,
    width=1280,
    bd=0,
    closeenough=8,
    highlightthickness=0,
    relief="ridge"
)

bgcanvas.pack(side="left", fill="both", expand=True)

# Title!
bgcanvas.create_rectangle(
    grid['x'][0], grid['y'][0],
    grid['x'][6], grid['y'][2],
    fill=colors['panel'][0],
    outline="")

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][0] + gaps[0],
    anchor="nw",
    text="Metro Kiev",
    fill=colors['title'],
    font=fonts['title']
)

# Credits!
bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][20] - gaps[2],
    anchor="sw",
    text="Práctica IA (2021) | Grupo 12",
    fill=colors['credits'],
    font=fonts['text']
)


# Station Label
last_station_hovered = StringVar()
station_label = Label(
    window,
    bg=colors['bg'],
    fg=colors['credits'],
    font=fonts['label'],
    justify='center',
    textvariable=last_station_hovered
)

station_label.place(x=grid['x'][14], y=grid['y'][5])

# Input!
bgcanvas.create_rectangle(
    grid['x'][0], grid['y'][2],
    grid['x'][6], grid['y'][6],
    fill=colors['panel'][1],
    outline="")

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][2] + gaps[0],
    anchor="nw",
    text="Desde",
    fill=colors['title'],
    font=fonts['text']
)

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][4],
    anchor="nw",
    text="Hasta",
    fill=colors['title'],
    font=fonts['text']
)

desde = StringVar()
desdeinput = Menubutton(
    window,
    background=colors['inputbg'][0],
    activebackground=colors['inputbg'][1],
    activeforeground=colors['input'],
    anchor='w',
    font=fonts['input'],
    fg=colors['input'],
    textvariable=desde,
    height=1,
    pady=6,
    width=2 * map_scale + 4
)

hasta = StringVar()
hastainput = Menubutton(
    window,
    background=colors['inputbg'][0],
    activebackground=colors['inputbg'][1],
    activeforeground=colors['input'],
    anchor='w',
    font=fonts['input'],
    fg=colors['input'],
    textvariable=hasta,
    height=1,
    pady=6,
    width=2 * map_scale + 4
)

cur_menu = desde
lineaslist = []


def f(station):
    cur_menu.set(f"{station.name} ({station.ukranian_name})")
    if cur_menu == desde:
        select_from(station)
    else:
        select_to(station)


for linea in Line.all:
    lineaslist.append(m := Menu(
        title=f"Linea {linea.number}",
        tearoff=0,
        font=fonts['input'],
        background=colors['inputbg'][0],
        activebackground=colors['inputbg'][1],
        activeforeground=colors['input']
    ))
    for station in linea.stations:
        m.add_command(label=f"{station.name} ({station.ukranian_name})",
                      command=partial(f, station))


def menu_lineas(menubutton):
    def change_strvar():
        global cur_menu
        if menubutton == desdeinput:
            cur_menu = desde
        else:
            cur_menu = hasta

    m = Menu(
        menubutton,
        title="Lineas",
        tearoff=0,
        postcommand=change_strvar,
        font=fonts['input'],
        background=colors['inputbg'][0],
        activebackground=colors['inputbg'][1],
        activeforeground=colors['input']
    )

    for linea in Line.all:
        m.add_cascade(
            label=f"Linea {linea.number}",
            menu=lineaslist[linea.number - 1]
        )
    return m


desdeinput.menu = menu_lineas(desdeinput)
desdeinput['menu'] = desdeinput.menu
desdeinput.place(x=grid['x'][0] + gaps[2], y=grid['y'][2] + 4 * gaps[0])
hastainput.menu = menu_lineas(hastainput)
hastainput['menu'] = hastainput.menu
hastainput.place(x=grid['x'][0] + gaps[2], y=grid['y'][4] + 3 * gaps[0])

# Go Button
go_button = bgcanvas.create_rectangle(
    grid['x'][5], grid['y'][2],
    grid['x'][6], grid['y'][6],
    fill=colors['button'][0],
    outline="",
    tags=("gobutton", "gobuttonbg")
)

bgcanvas.create_text(
    grid['x'][5] + grid['x'][1] / 2, grid['y'][4] - gaps[0],
    text='>',
    font=fonts['button'],
    fill=colors['title'],
    tags=("gobutton", "gobuttontext")
)


def active_button(event):
    if event.type == EventType.Enter:
        bgcanvas.itemconfigure(go_button, fill=colors['button'][1])
    elif event.type == EventType.Leave:
        bgcanvas.itemconfigure(go_button, fill=colors['button'][0])


bgcanvas.tag_bind("gobuttonbg", "<Leave>", active_button)
bgcanvas.tag_bind("gobutton", "<Enter>", active_button)

transbordos_string = StringVar()
transbordos_label = Label(
    window,
    bg=colors['bg'],
    fg=colors['credits'],
    font=fonts['text'],
    justify='left',
    textvariable=transbordos_string
)
transbordos_label.place(x=grid['x'][1], y=grid['y'][8] + gaps[0])

time_string = StringVar()
time_label = Label(
    window,
    bg=colors['bg'],
    fg=colors['credits'],
    font=fonts['label'],
    textvariable=time_string
)
time_label.place(x=grid['x'][1], y=grid['y'][7])

map_corner = grid['x'][8], grid['y'][3]
linewidth = int(0.4 * map_scale)
stationrad = int(0.5 * map_scale)


def label_station(station, event):
    last_station_hovered.set(station.name)


def transform_point(point):
    return [(point[i] * map_scale + map_corner[i]) for i in range(2)]

selected_from = None

def select_from(station):
    global selected_from
    if selected_from:
        bgcanvas.itemconfigure(f"ID {selected_from.id}", fill=colors['bg'])
    selected_from = station
    bgcanvas.itemconfigure(f"ID {station.id}",
                           fill=colors['lines'][station.line - 1])


selected_to = None


def select_to(station):
    global selected_to
    if selected_to:
        bgcanvas.itemconfigure(f"ID {selected_to.id}", fill=colors['bg'])
    selected_to = station
    bgcanvas.itemconfigure(f"ID {station.id}",
                           fill=colors['lines'][station.line - 1])


def select_station(station, event):
    global cur_menu
    if event.num == 3:
        cur_menu = hasta
    else:
        cur_menu = desde
    f(station)


current_path = []
current_len = 0
transfers = []

def path_to(origin, destination):
    global current_path
    for station in current_path:
        bgcanvas.itemconfigure(f"Path {station.id}",
                               fill=colors['lines_i'][station.line - 1])
    for station in transfers:
        bgcanvas.itemconfigure(f"ID {station.id}",
                               fill=colors['bg'])
        transfers.remove(station)
    current_path, current_len = short_path(origin, destination)
    prev = None
    for station in current_path:
        if prev:
            i1, i2 = min(station.id, prev.id), max(station.id, prev.id)
            bgcanvas.itemconfigure(f"Path {i1}-{i2}",
                                   fill=colors['lines'][station.line - 1])
            if station.line != prev.line:
                transfers.append(station)
                transfers.append(prev)
                bgcanvas.itemconfigure(f"ID {station.id}",
                                       fill=colors['lines'][station.line - 1])
                bgcanvas.itemconfigure(f"ID {prev.id}",
                                       fill=colors['lines'][prev.line - 1])

        prev = station
    if transfers:
        transbordos_string.set("Transbordo en:\n" + transfers[0].name)
    time_string.set(f"{int(current_len / 900)} min")


def find_path(event):
    origin = desde.get().split('(')[0]
    destination = hasta.get().split('(')[0]
    if origin and destination:
        path_to(Station.all[origin[:-1]], Station.all[destination[:-1]])


i, prevline = -1, 1
for line in symbolicmap['lines']:
    i = i + 1 if line[0] == prevline else 0
    prevline = line[0]
    points = [transform_point(p) for p in line[1:]]
    stationid = line[0] * 100 + (10 + i)
    bgcanvas.create_line(
        *points,
        fill=colors['lines_i'][line[0] - 1],
        width=linewidth if line[0] else 3 * linewidth,
        capstyle='round',
        joinstyle='round',
        tags=("Path", f"Path {stationid}", f"Path {stationid + 1}", f"Path {stationid}-{stationid + 1}")
    )

for station in Station.all.values():
    line = station.line
    point = transform_point(station.coords)
    bgcanvas.create_oval(
        point[0] - stationrad, point[1] - stationrad,
        point[0] + stationrad, point[1] + stationrad,
        fill=colors['bg'],
        width=int(2 * map_scale / 10),
        outline=colors['lines'][line - 1],
        activefill=colors['lines'][line - 1],
        activewidth=int(4 * map_scale / 10),
        tags=("Station", f"Line {line}", f"ID {station.id}")
    )
    bgcanvas.tag_bind(f"ID {station.id}", "<Enter>", partial(label_station, station))
    bgcanvas.tag_bind(f"ID {station.id}", "<1>", partial(select_station, station))
    bgcanvas.tag_bind(f"ID {station.id}", "<3>", partial(select_station, station))


bgcanvas.tag_bind("gobutton", "<1>", find_path)

window.resizable(True, True)
window.attributes('-fullscreen', True)
window.mainloop()
