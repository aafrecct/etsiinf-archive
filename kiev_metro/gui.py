from pathlib import Path
from json import load
from tkinter import Tk, Canvas, Entry, Text, Button


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)


window = Tk()

# Options!
screen_width, screen_height = window.winfo_screenwidth(), window.winfo_screenheight()
# screen_width, screen_height = 1920, 1080
map_scale = {480: 8, 720: 10, 768: 15, 1080:20}[screen_height]
gaps = (screen_height // 60, screen_height // 50, screen_height // 40)
grid = {
    'x': [i * ((screen_width)/ 20) for i in range(21)], 
    'y': [i * ((screen_height)/ 20) for i in range(21)]
}
fonts = {
    'title': (),
    'text': (),
    'stop': ()
}
colors = {
    'bg': '#1A1D20',
    'title': '#EEEEEE',
    'panel1': '#282828',
    'panel2': '#303030',
    'panel3': '#383838',
    'debugred': '#FF0000',
    'debugblue': '#0000FF',
    'lines': ['#f24467', '#00A142', '#2E7CFF'],
    'lines_i': ['#3A282C', '#36473D', '#374050']
}

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
    grid['x'][10], grid['y'][2],
    fill=colors['panel1'],
    outline="")

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][0] + gaps[0],
    anchor="nw",
    text="Práctica de Inteligencia Artificial",
    fill=colors['title'],
    font=("Cascadia Code", -28)
)

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][0] + 2 * gaps[2],
    anchor="nw",
    text="Metro de Kiev   Grupo 12",
    fill=colors['title'],
    font=("Cascadia Code", -20)
)

# Input!
bgcanvas.create_rectangle(
    grid['x'][0], grid['y'][2],
    grid['x'][6], grid['y'][5],
    fill=colors['panel2'],
    outline="")

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][2] + gaps[0],
    anchor="nw",
    text="Desde",
    fill=colors['title'],
    font=("Cascadia Code", -18)
)

bgcanvas.create_text(
    grid['x'][0] + gaps[2], grid['y'][2] + 5 * gaps[0],
    anchor="nw",
    text="Hasta",
    fill=colors['title'],
    font=("Cascadia Code", -18)
)

desdeinput = Entry(
    window,
    bg=colors['debugred'],
    bd=0
)

hastainput = Entry(
    window,
    bg=colors['debugred'],
    bd=0
)

desdeinput.place(x=grid['x'][0] + gaps[2], y=grid['y'][2] + 3 * gaps[0])
hastainput.place(x=grid['x'][0] + gaps[2], y=grid['y'][2] + 7 * gaps[0])


buscarbutton = Button(
    window,
    text="Buscar",
    bg=colors['debugblue'],
    padx=18,
    pady=48,
    bd=0
)

buscarbutton.place(x=grid['x'][5], y=grid['y'][2])


bgcanvas.create_rectangle(
    10, 260.0,
    356, 600.0,
    fill=colors['panel2'],
    outline="")

with open('data/symbolicmap.json', 'r') as fd:
    smap = load(fd)

map_corner = grid['x'][7], grid['y'][3]
linewidth = int(0.3 * map_scale)
stationrad = int(0.5 * map_scale)

def transform_point(point):
    return [(point[i] * map_scale + map_corner[i]) for i in range(2)]

for line in smap['lines']:
    origin = transform_point(line[1])
    dest = transform_point(line[2])
    bgcanvas.create_line(
        *origin, *dest,
        fill=colors['lines_i'][line[0] - 1],
        width=linewidth
    )


for point in smap['points']:
    line = point[0]
    point = transform_point(point[1:])
    bgcanvas.create_oval(
        point[0] - stationrad, point[1] - stationrad, 
        point[0] + stationrad, point[1] + stationrad, 
        fill=colors['bg'],
        width=int(2 * map_scale / 10),
        outline= colors['lines'][line - 1],
        activefill=colors['lines'][line - 1],
        activewidth= int(4 * map_scale / 10),
        tags=(f"Line {line}", f"ID")
    )


window.resizable(True, True)
window.attributes('-fullscreen', True)
window.mainloop()
