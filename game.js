"use strict";
const KEY="pixel-farm-seasons-v1",names=["🌸 Primavera","☀️ Verão","🍂 Outono","❄️ Inverno"];
const empty=()=>({growth:0,watered:false,planted:false});
const initial=()=>({day:1,coins:20,harvest:0,selected:0,plots:Array.from({length:16},empty)});
function valid(s){return s&&Number.isInteger(s.day)&&s.day>0&&Number.isFinite(s.coins)&&s.coins>=0&&Number.isInteger(s.harvest)&&Array.isArray(s.plots)&&s.plots.length===16&&s.plots.every(p=>typeof p.planted==="boolean"&&typeof p.watered==="boolean"&&Number.isInteger(p.growth)&&p.growth>=0&&p.growth<=2)}
let state;try{const saved=JSON.parse(localStorage.getItem(KEY));state=valid(saved)?saved:initial()}catch{state=initial()}
const el=id=>document.getElementById(id);const note=t=>{el("message").textContent=t};
function save(){try{localStorage.setItem(KEY,JSON.stringify(state))}catch{}}
function render(){el("season").textContent=names[Math.floor((state.day-1)/7)%4];el("day").textContent="📅 Dia "+state.day;el("coins").textContent="🪙 "+state.coins+" moedas";el("seeds").textContent="🌱 Sementes: ilimitadas";el("harvest").textContent="🧺 Colheitas: "+state.harvest;el("farm").replaceChildren(...state.plots.map((p,i)=>{const b=document.createElement("button");b.className="plot"+(i===state.selected?" selected":"");b.textContent=!p.planted?"🟫":p.growth===2?"🥕":p.growth===1?"🌿":"🌱";b.setAttribute("aria-label","Terreno "+(i+1)+(p.planted?", plantado":", vazio"));b.setAttribute("aria-pressed",String(i===state.selected));b.onclick=()=>{state.selected=i;render();note("Terreno "+(i+1)+" selecionado.")};return b}));save()}
el("plant").onclick=()=>{const p=state.plots[state.selected];if(p.planted)return note("Este terreno já tem uma planta.");if(state.coins<2)return note("Você precisa de 2 moedas para plantar.");state.coins-=2;state.plots[state.selected]={planted:true,growth:0,watered:false};note("Semente plantada! Regue para crescer.");render()};
el("water").onclick=()=>{const p=state.plots[state.selected];if(!p.planted)return note("Plante antes de regar.");if(p.growth===2)return note("Sua planta está pronta para colher.");p.watered=true;note("Terreno regado! Avance um dia.");render()};
el("collect").onclick=()=>{const p=state.plots[state.selected];if(!p.planted||p.growth<2)return note("Esta planta ainda não está pronta.");state.coins+=6;state.harvest++;state.plots[state.selected]=empty();note("Colheita concluída! +6 moedas.");render()};
el("next").onclick=()=>{for(const p of state.plots){if(p.planted&&p.watered&&p.growth<2)p.growth++;p.watered=false}state.day++;note("Um novo dia começou!");render()};
el("reset").onclick=()=>{if(confirm("Reiniciar toda a fazenda?")){state=initial();note("Fazenda reiniciada.");render()}};
render();note("Selecione um terreno para começar!");