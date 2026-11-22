#!/usr/bin/env python3
"""Read the skill's reference GDS (pure Python, no GDS library needed).

  gdsref.py list  [GDS]                     cell names + bounding boxes
  gdsref.py dump  CELL [GDS] [LAYER ...]    shapes per layer, in gate-pitch units (bbox, or points for polygons)
  gdsref.py png   CELL OUT.png [GDS] [LAYER ...]   quick-look render (needs matplotlib)
  gdsref.py png   ARRAY OUT.png --window X0 Y0 X1 Y1   detailed render of a window of an array (u)
  gdsref.py place CELL [GDS]                placements of an array cell: cell, x, y, orientation

Layer names are the generic ones in references/layers.md.  Default GDS = ../assets/finfet_stdcell_ref.gds.
"""
import os,struct,sys
HERE=os.path.dirname(os.path.abspath(__file__))
DEF=os.path.join(HERE,"..","assets","finfet_stdcell_ref.gds")
LAYERS={1:"FIN",2:"OD",3:"PO",4:"PODE",5:"POEDGE",6:"CPO",7:"NW",8:"NIMP",9:"PIMP",10:"VTN",11:"VTP",12:"TO",13:"PRBND",
        20:"MD",21:"CMD",22:"MD_RT",23:"MD_RC",24:"MP",30:"V0",31:"V0R",32:"M1",33:"M1RAIL",40:"V1",41:"M2",132:"M1_TXT",141:"M2_TXT"}
def r8(b):
    s=-1 if b[0]&0x80 else 1; e=(b[0]&0x7f)-64; m=int.from_bytes(b[1:8],"big")/2**56; return s*m*16**e
def flat(cells,name,depth=0):
    """shapes of a cell with sub-cell references expanded (one level is all the examples use)"""
    import math
    out=[]
    for e in cells[name]:
        if e["k"]!="ref": out.append(e); continue
        th=math.radians(e["ang"]); c,s_=math.cos(th),math.sin(th); ox,oy=e["xy"][0]
        for f in flat(cells,e["sname"],depth+1):
            pts=[]
            for x,y in f["xy"]:
                if e["mx"]: y=-y
                pts.append((ox+c*x-s_*y,oy+s_*x+c*y))
            g=dict(f); g["xy"]=pts; out.append(g)
    return out
def read(path):
    data=open(path,"rb").read(); i=0; cells={}; cur=None; el=None; uu=1.0
    while i<len(data):
        n,rt,dt=struct.unpack(">HBB",data[i:i+4]); body=data[i+4:i+n]; i+=n
        if n==0: break
        if rt==0x03: uu=r8(body[0:8])      # UNITS: user units per db unit
        elif rt==0x06: cur=body.rstrip(b"\0").decode(); cells[cur]=[]
        elif rt in (0x08,0x0C): el={"k":"poly" if rt==0x08 else "text"}
        elif rt==0x0A: el={"k":"ref","layer":None,"mx":False,"ang":0.0}
        elif rt==0x12 and el is not None: el["sname"]=body.rstrip(b"\0").decode()
        elif rt==0x1A and el is not None: el["mx"]=bool(body[0]&0x80)
        elif rt==0x1C and el is not None: el["ang"]=r8(body[0:8])
        elif rt==0x0D: el["layer"]=struct.unpack(">h",body)[0]
        elif rt==0x10:
            v=struct.unpack(f">{len(body)//4}i",body); el["xy"]=[(v[j]*uu,v[j+1]*uu) for j in range(0,len(v),2)]
        elif rt==0x19: el["text"]=body.rstrip(b"\0").decode()
        elif rt==0x11 and el is not None: cells[cur].append(el); el=None
    return cells
def bbox(pts): xs=[p[0] for p in pts]; ys=[p[1] for p in pts]; return min(xs),min(ys),max(xs),max(ys)
def main():
    a=sys.argv[1:]
    if not a: print(__doc__); return
    cmd=a[0]
    if cmd=="list":
        cells=read(a[1] if len(a)>1 else DEF)
        for c,els in cells.items():
            if any(e["k"]=="ref" for e in els):
                print(f"{c:22s} array of {sum(e['k']=='ref' for e in els)} cell placements"); continue
            b=[e for e in els if e["k"]=="poly" and LAYERS.get(e["layer"])=="PRBND"]
            print(f"{c:22s}", "PRBND %.3f,%.3f - %.3f,%.3f"%bbox(b[0]["xy"]) if b else "")
        return
    cell=a[1]; rest=a[2:]
    if cmd=="place":
        for e in read(rest[0] if rest else DEF)[cell]:
            if e["k"]=="ref":
                o=("MX" if e["mx"] else "")+("R%d"%round(e["ang"]) if e["ang"] else ("" if e["mx"] else "R0"))
                print(f"{e['sname']:22s} {e['xy'][0][0]:8.3f} {e['xy'][0][1]:8.3f} {o}")
        return
    out=None
    if cmd=="png": out=rest[0]; rest=rest[1:]
    gds=DEF
    if rest and rest[0].endswith(".gds"): gds=rest[0]; rest=rest[1:]
    win=None
    if "--window" in rest:
        k=rest.index("--window"); win=tuple(map(float,rest[k+1:k+5])); rest=rest[:k]+rest[k+5:]
    want=set(rest)
    cells=read(gds)
    if cmd=="png" and win is None and any(e["k"]=="ref" for e in cells[cell]):
        return floorplan(cells,cell,out)
    els=[e for e in flat(cells,cell) if not want or LAYERS.get(e["layer"]) in want]
    if win:
        els=[e for e in els if (lambda b: b[2]>=win[0] and b[0]<=win[2] and b[3]>=win[1] and b[1]<=win[3])(bbox(e["xy"]))]
    if cmd=="dump":
        for e in sorted(els,key=lambda e:(e["layer"],bbox(e["xy"]))):
            ln=LAYERS.get(e["layer"],e["layer"])
            if e["k"]=="text": print(f"{ln:7s} TEXT {e['text']} @ {e['xy'][0][0]:.3f},{e['xy'][0][1]:.3f}"); continue
            pts=e["xy"][:-1]; b=bbox(pts)
            print(f"{ln:7s} {b[0]:.3f},{b[1]:.3f} - {b[2]:.3f},{b[3]:.3f}"+("" if len(pts)==4 else "  poly "+" ".join(f"({x:.3f},{y:.3f})" for x,y in pts)))
        return
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt; from matplotlib.patches import Polygon
    sty={"OD":("#9be39b",.55,1),"PO":("#e06666",.55,2),"PODE":("#7f0000",.35,2),"CPO":("cyan",.6,3),"MD":("#b48cff",.6,4),
         "CMD":("yellow",.5,4),"MD_RT":("#6a3fd0",.7,4),"MD_RC":("#d0b0ff",.7,4),"MP":("orange",.85,5),"V0":("black",1,8),
         "V0R":("#444444",1,8),"M1":("#5b9cff",.5,6),"V1":("white",1,10),"M2":("#2fb82f",.4,9),"NW":("none",1,0)}
    fig,ax=plt.subplots(figsize=(14,7))
    for e in els:
        ln=LAYERS.get(e["layer"])
        if e["k"]=="text":
            ax.text(*e["xy"][0],e["text"],color="red",fontsize=10,weight="bold",zorder=20); continue
        if ln=="PRBND":
            ax.add_patch(Polygon(e["xy"],fill=False,ec="k",lw=1.2,ls="--",zorder=15)); continue
        if ln=="NW": ax.add_patch(Polygon(e["xy"],fill=False,ec="#c08000",lw=1,zorder=0)); continue
        if ln not in sty: continue
        c,al,z=sty[ln]; ax.add_patch(Polygon(e["xy"],fc=c,ec="k" if ln in("V0","V1","V0R") else "none",alpha=al,lw=.4,zorder=z))
    ax.autoscale()
    if win: ax.set_xlim(win[0],win[2]); ax.set_ylim(win[1],win[3])
    ax.set_aspect("equal"); ax.set_title(cell+(" window %g,%g-%g,%g"%win if win else "")); fig.tight_layout(); fig.savefig(out,dpi=110); print(out)
def floorplan(cells,cell,out):
    """array overview: one box per placed cell, coloured by master"""
    import math
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt; from matplotlib.patches import Rectangle
    refs=[e for e in cells[cell] if e["k"]=="ref"]
    masters=sorted({e["sname"] for e in refs}); cmap=plt.get_cmap("tab20")
    col={m:cmap(i%20) for i,m in enumerate(masters)}
    fig,ax=plt.subplots(figsize=(16,9))
    for e in refs:
        b=[f for f in cells[e["sname"]] if f["k"]=="poly" and LAYERS.get(f["layer"])=="PRBND"]
        x0,y0,x1,y1=bbox(b[0]["xy"]); th=math.radians(e["ang"]); c,s_=round(math.cos(th)),round(math.sin(th)); ox,oy=e["xy"][0]
        pts=[]
        for x,y in ((x0,y0),(x1,y1)):
            if e["mx"]: y=-y
            pts.append((ox+c*x-s_*y,oy+s_*x+c*y))
        (a,b_),(c_,d)=pts
        ax.add_patch(Rectangle((min(a,c_),min(b_,d)),abs(c_-a),abs(d-b_),fc=col[e["sname"]],ec="k",lw=0.1))
    ax.autoscale(); ax.set_aspect("equal"); ax.set_title(f"{cell}: {len(refs)} placements (floorplan)")
    ax.legend(handles=[Rectangle((0,0),1,1,fc=col[m]) for m in masters],labels=masters,loc="center left",bbox_to_anchor=(1.01,0.5),fontsize=7)
    fig.tight_layout(); fig.savefig(out,dpi=110); print(out)
if __name__=="__main__": main()
