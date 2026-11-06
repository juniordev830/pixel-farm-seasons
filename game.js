'use strict';
(() => {
const canvas=document.getElementById('game'),ctx=canvas.getContext('2d');
const clock=document.getElementById('clock'),energyUI=document.getElementById('energy'),hungerUI=document.getElementById('hunger'),message=document.getElementById('message');
const keys=new Set(),player={x:-180,z:80,energy:100,hunger:0,coins:40,seeds:8,harvest:0,vehicle:'foot',land:0},world={minute:420,day:1};
const plots=Array.from({length:12},(_,i)=>({x:-180+(i%4)*85,z:80+Math.floor(i/4)*80,planted:-1,watered:false}));
const saveKey='pixel-farm-seasons-v1';
function notice(s){message.textContent=s;}
function save(){try{localStorage.setItem(saveKey,JSON.stringify({player,world,plots,lastMealDay}));notice('Jogo salvo!');}catch{notice('Não foi possível salvar neste navegador.');}}
function load(){try{
 const s=JSON.parse(localStorage.getItem(saveKey)||'null');if(!s)return;
 if(!s.player||!s.world||!Array.isArray(s.plots)||!Number.isFinite(s.world.minute)||!Number.isInteger(s.world.day)||s.world.day<1)throw Error('save inválido');
 const safeNumber=(value,fallback,min,max)=>Number.isFinite(value)?Math.max(min,Math.min(max,value)):fallback;
 for(const k of ['x','z'])player[k]=safeNumber(s.player[k],player[k],-10000,10000);
 for(const k of ['energy','hunger'])player[k]=safeNumber(s.player[k],player[k],0,100);
 for(const k of ['coins','seeds','harvest','land'])player[k]=Math.floor(safeNumber(s.player[k],player[k],0,1000000));
 player.vehicle=['foot','fusca','bike'].includes(s.player.vehicle)?s.player.vehicle:'foot';
 world.day=s.world.day;world.minute=safeNumber(s.world.minute,420,0,1439.999);
 s.plots.slice(0,plots.length).forEach((p,i)=>{if(!p||typeof p!=='object')return;plots[i].planted=Number.isFinite(p.planted)?p.planted:-1;plots[i].watered=p.watered===true;});
 lastMealDay=Number.isInteger(s.lastMealDay)?s.lastMealDay:0;notice('Jogo carregado!');
 }catch{notice('Save inválido: iniciando nova partida.');}}

function nearestPlot(){return plots.reduce((a,p)=>Math.hypot(p.x-player.x,p.z-player.z)<Math.hypot(a.x-player.x,a.z-player.z)?p:a,plots[0]);}
function farm(){const p=nearestPlot();if(Math.hypot(p.x-player.x,p.z-player.z)>95)return notice('Aproxime-se da horta.');if(p.planted<0){if(player.seeds<=0)return notice('Sem sementes! Aperte B para comprar.');p.planted=world.day*1440+world.minute;p.watered=false;player.seeds--;notice('Semente plantada! Aperte F novamente para regar.');}else if(!p.watered){p.watered=true;notice('Plantação regada. Aguarde um dia do jogo.');}else if(world.day*1440+world.minute-p.planted>=1440){p.planted=-1;p.watered=false;player.harvest++;notice('Colheita realizada! Aperte V para vender.');}else notice('Ainda está crescendo.');}
function vehicle(){if(Math.hypot(player.x+65,player.z-30)>100)return notice('Aproxime-se da garagem para usar um veículo.');player.vehicle=player.vehicle==='foot'?'fusca':player.vehicle==='fusca'?'bike':'foot';notice(player.vehicle==='fusca'?'Entrou no Fusca azul.':player.vehicle==='bike'?'Pegou a bicicleta Monark vermelha.':'Saiu do veículo.');}
function expand(){const cost=100*(player.land+1);if(player.coins<cost)return notice('Expansão custa '+cost+' moedas.');player.coins-=cost;player.land++;notice('Terreno expandido!');}
function trade(k){if(k==='b'){if(player.coins<5)return notice('Moedas insuficientes.');player.coins-=5;player.seeds+=3;notice('Comprou três sementes.');}else if(player.harvest){player.coins+=player.harvest*12;player.harvest=0;notice('Colheita vendida!');}else notice('Não há colheita para vender.');}

let last=performance.now(),lastMealDay=0,mealWarningDay=0,autosaveElapsed=0;
const clamp=(n,min,max)=>Math.max(min,Math.min(max,n));
function eat(){player.hunger=clamp(player.hunger-65,0,100);player.energy=clamp(player.energy+12,0,100);lastMealDay=world.day;message.textContent='Almoço feito! Energia recuperada.';}
addEventListener('keydown',e=>{const k=e.key.toLowerCase();if(['arrowup','arrowdown','arrowleft','arrowright',' '].includes(k))e.preventDefault();keys.add(k);if(!e.repeat&&k==='e')eat();if(!e.repeat&&k==='f')farm();if(!e.repeat&&(k==='b'||k==='v'))trade(k);if(!e.repeat&&k==='t')vehicle();if(!e.repeat&&k==='x')expand();if(!e.repeat&&k==='p')save();if(!e.repeat&&k==='l')load();if(!e.repeat&&k==='r'){player.energy=clamp(player.energy+25,0,100);message.textContent='Você descansou um pouco.';}});
addEventListener('keyup',e=>keys.delete(e.key.toLowerCase()));
addEventListener('blur',()=>keys.clear());
for(const button of document.querySelectorAll('.touch button')){
 const hold=button.dataset.hold,action=button.dataset.key;
 if(hold){const down=e=>{e.preventDefault();keys.add(hold);};const up=e=>{e.preventDefault();keys.delete(hold);};button.addEventListener('pointerdown',down);button.addEventListener('pointerup',up);button.addEventListener('pointercancel',up);button.addEventListener('pointerleave',up);}
 else button.addEventListener('click',()=>{if(action==='f')farm();else if(action==='e')eat();else if(action==='p')save();else if(action==='t')vehicle();else if(action==='x')expand();else if(action==='b'||action==='v')trade(action);});
}
function update(dt){
world.minute+=dt*2;autosaveElapsed+=dt;if(autosaveElapsed>=60){autosaveElapsed=0;try{localStorage.setItem(saveKey,JSON.stringify({player,world,plots,lastMealDay}));}catch{}}while(world.minute>=1440){world.minute-=1440;world.day++;lastMealDay=0;}
const hour=world.minute/60;const night=hour>=19||hour<6;
player.hunger=clamp(player.hunger+dt*.12,0,100);
if(hour>=12&&hour<18&&lastMealDay!==world.day){player.hunger=clamp(player.hunger+dt*.25,0,100);player.energy=clamp(player.energy-dt*.18,0,100);if(mealWarningDay!==world.day){message.textContent='Eita, já passou da hora de almoçar!';mealWarningDay=world.day;}}
if(hour>=22||hour<5)player.energy=clamp(player.energy-dt*.24,0,100);
if(player.hunger>=80)player.energy=clamp(player.energy-dt*.3,0,100);
let dx=Number(keys.has('d')||keys.has('arrowright'))-Number(keys.has('a')||keys.has('arrowleft'));
let dz=Number(keys.has('w')||keys.has('arrowup'))-Number(keys.has('s')||keys.has('arrowdown'));
const len=Math.hypot(dx,dz)||1,speed=(player.vehicle==='fusca'?150:player.vehicle==='bike'?90:55)*(player.energy<25?.45:1);
const limit=400+player.land*200;player.x=clamp(player.x+dx/len*speed*dt,-limit,limit);player.z=clamp(player.z+dz/len*speed*dt,-limit,limit);
if((dx||dz)&&player.vehicle==='foot')player.energy=clamp(player.energy-dt*.045,0,100);
clock.textContent='🪙 '+player.coins+' | 🌱 '+player.seeds+' | 🥕 '+player.harvest+' | Dia '+world.day+' · '+String(Math.floor(world.minute/60)).padStart(2,'0')+':'+String(Math.floor(world.minute%60)).padStart(2,'0');
energyUI.textContent='Energia: '+Math.round(player.energy);hungerUI.textContent='Fome: '+Math.round(player.hunger);
}
function render(){
 const w=canvas.width,h=canvas.height,horizon=Math.round(h*.37);
 const hour=world.minute/60,night=hour>=19||hour<6,dusk=hour>=17&&hour<19;
 const seasons=['Primavera','Verão','Outono','Inverno'],seasonIndex=Math.floor((world.day-1)/7)%4,season=seasons[seasonIndex];
 const rainy=world.day%5===0,autumn=seasonIndex===2,winter=seasonIndex===3;
 const wind=Math.sin(world.minute*.08)*3;
 const sky=night?'#152842':dusk?'#db9977':rainy?'#849aa7':winter?'#b9d3db':'#91c9e5';
 ctx.fillStyle=sky;ctx.fillRect(0,0,w,horizon);
 // Distant hills use slower parallax than foreground.
 function polygon(points,color){ctx.fillStyle=color;ctx.beginPath();ctx.moveTo(points[0][0],points[0][1]);for(let i=1;i<points.length;i++)ctx.lineTo(points[i][0],points[i][1]);ctx.fill();}
 const sunX=w*.81,sunY=h*.13;
 ctx.fillStyle=night?'#f1e8c4':dusk?'#f8d18b':'#fff1b4';ctx.beginPath();ctx.arc(sunX,sunY,night?19:29,0,Math.PI*2);ctx.fill();
 const hillOffset=player.x*.08;
 polygon([[-100-hillOffset,horizon],[130-hillOffset,horizon-85],[340-hillOffset,horizon-18],[570-hillOffset,horizon-110],[w+150,horizon],[w,horizon]],night?'#314c54':'#77a69a');
 polygon([[-100,horizon],[190-player.x*.14,horizon-43],[450-player.x*.14,horizon],[720-player.x*.14,horizon-70],[w+100,horizon]],night?'#344d47':'#619474');
 ctx.fillStyle=night?'#354e38':winter?'#8caa9a':autumn?'#9c9b54':'#75a758';ctx.fillRect(0,horizon,w,h-horizon);
 // Dirt lane with perspective, plus subtle ground bands.
 polygon([[w*.42,horizon],[w*.57,horizon],[w*.97,h],[w*.03,h]],night?'#6a604e':'#c0a17a');
 polygon([[w*.46,horizon],[w*.50,horizon],[w*.68,h],[w*.61,h]],night?'#766952':'#dbc49a');
 for(let i=0;i<8;i++){const y=horizon+25+i*44;ctx.fillStyle=night?'#45623c':'#8bb869';ctx.fillRect(0,y,w,2);}
 const offset=player.x*.65;
 function building(x,y,bw,bh,wall,roof){
  ctx.fillStyle='rgba(26,36,26,.22)';ctx.fillRect(x-offset+9,y+bh-3,bw+15,12);
  ctx.fillStyle=wall;ctx.fillRect(x-offset,y,bw,bh);
  ctx.fillStyle=roof;polygon([[x-offset-14,y],[x-offset+bw*.5,y-55],[x-offset+bw+14,y]],roof);
  ctx.fillStyle='#694f3c';ctx.fillRect(x-offset+bw*.42,y+bh*.52,bw*.22,bh*.48);
  ctx.fillStyle=night?'#f2c56d':'#8cc8df';ctx.fillRect(x-offset+19,y+28,34,29);
  ctx.fillStyle='#faf0d7';ctx.fillRect(x-offset+35,y+28,3,29);
 }
 building(90,215,180,129,'#e5cba0','#a75441');
 building(310,247,155,94,'#b8b4a4','#765b4c');
 // Trees and fencing create a readable foreground.
 for(let i=0;i<11;i++){
  const tx=((i*151-player.x*.35)%1200+1200)%1200-90;
  const ty=horizon+18+(i%3)*13;
  ctx.fillStyle='#69533e';ctx.fillRect(tx,ty-18,11,60);
  ctx.fillStyle=night?'#2e5d3b':winter?'#69867b':autumn?'#b47737':'#367846';
  ctx.beginPath();ctx.arc(tx+5+wind,ty-28,28,0,Math.PI*2);ctx.fill();
  ctx.fillStyle=night?'#3c6b45':winter?'#8ba49a':autumn?'#c18b43':'#4f9752';ctx.beginPath();ctx.arc(tx-8+wind*1.3,ty-38,17,0,Math.PI*2);ctx.fill();
 }
 // Draw distant plots before near plots for depth.
 const sorted=plots.slice().sort((p,q)=>q.z-p.z);
 for(const p of sorted){
  const x=w/2+(p.x-player.x)*.77,y=h*.62+(p.z-player.z)*.37;
  if(y<horizon||y>h+35)continue;
  ctx.fillStyle='#49392b';ctx.fillRect(x-27,y-10,54,30);
  ctx.fillStyle='#8c5b3c';ctx.fillRect(x-24,y-13,48,24);
  ctx.fillStyle='#ae7950';for(let k=0;k<3;k++)ctx.fillRect(x-19,y-9+k*7,38,2);
  if(p.planted>=0){
   const grown=p.watered?'#4ba74c':'#a2af52';
   for(let k=-1;k<=1;k++){ctx.fillStyle=grown;ctx.fillRect(x+k*12-2,y-22,4,18);ctx.beginPath();ctx.arc(x+k*12,y-24,6,0,Math.PI*2);ctx.fill();}
  }
 }
 // Parked blue Beetle and red Monark bicycle near garage.
 const carX=390-offset,carY=343;
 ctx.fillStyle='#23374b';ctx.fillRect(carX+6,carY-19,58,22);
 ctx.fillStyle='#2467b3';ctx.fillRect(carX,carY-10,78,27);
 polygon([[carX+15,carY-19],[carX+30,carY-34],[carX+53,carY-34],[carX+65,carY-19]],'#367fc6');
 ctx.fillStyle='#b6d7df';ctx.fillRect(carX+31,carY-30,19,11);
 ctx.fillStyle='#272a2b';for(const x of [carX+15,carX+62]){ctx.beginPath();ctx.arc(x,carY+17,10,0,Math.PI*2);ctx.fill();}
 const bikeX=489-offset,bikeY=360;
 ctx.strokeStyle='#bc3d38';ctx.lineWidth=3;ctx.beginPath();ctx.moveTo(bikeX,bikeY);ctx.lineTo(bikeX+16,bikeY-19);ctx.lineTo(bikeX+32,bikeY);ctx.lineTo(bikeX,bikeY);ctx.lineTo(bikeX+25,bikeY-19);ctx.stroke();
 ctx.strokeStyle='#30383c';ctx.beginPath();ctx.arc(bikeX,bikeY,11,0,Math.PI*2);ctx.moveTo(bikeX+43,bikeY);ctx.arc(bikeX+43,bikeY,11,0,Math.PI*2);ctx.stroke();
 // Farmer stays centered as the world scrolls around them.
 const px=w*.5,py=h*.77;
 ctx.fillStyle='rgba(0,0,0,.2)';ctx.beginPath();ctx.arc(px,py+55,24,0,Math.PI*2);ctx.fill();
 ctx.fillStyle=player.vehicle==='fusca'?'#245d9e':player.vehicle==='bike'?'#b83d36':'#394b40';
 ctx.fillRect(px-12,py+15,10,42);ctx.fillRect(px+4,py+15,10,42);
 ctx.fillStyle='#3c7197';ctx.fillRect(px-19,py-24,38,48);
 ctx.fillStyle='#d9aa83';ctx.fillRect(px-27,py-17,8,33);ctx.fillRect(px+19,py-17,8,33);
 ctx.beginPath();ctx.arc(px,py-43,18,0,Math.PI*2);ctx.fill();
 ctx.fillStyle='#6c5139';ctx.fillRect(px-19,py-60,38,9);ctx.fillRect(px-13,py-70,26,14);
 if(rainy){ctx.strokeStyle='rgba(193,219,234,.65)';ctx.lineWidth=2;for(let i=0;i<75;i++){const x=(i*139+world.minute*17)%w,y=(i*89+world.minute*27)%h;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(x-5,y+15);ctx.stroke();}}
 if(night){ctx.fillStyle='rgba(7,15,29,.28)';ctx.fillRect(0,0,w,h);}
 ctx.fillStyle='rgba(20,39,30,.78)';ctx.fillRect(12,10,w-24,42);
 ctx.fillStyle='rgba(20,39,30,.72)';ctx.fillRect(12,h-64,Math.min(w-24,485),52);
 ctx.fillStyle='#f6dfaa';ctx.font='15px system-ui';ctx.fillText('🪙 '+player.coins+'   🌱 '+player.seeds+'   🥕 '+player.harvest+'   ⚡ '+Math.round(player.energy)+'   🍲 '+Math.round(player.hunger),25,h-32);
 ctx.fillStyle='#f7f4e7';ctx.font='17px system-ui';
 ctx.fillText('PIXEL FARM SEASONS  •  '+season+(rainy?'  •  Chuva':'')+'  •  F plantar  •  T veículo  •  X expandir',26,37);
}
function frame(now){const dt=Math.min((now-last)/1000,.05);last=now;update(dt);render();requestAnimationFrame(frame);}requestAnimationFrame(frame);
load();
})();