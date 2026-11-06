'use strict';
(() => {
const canvas=document.getElementById('game'),ctx=canvas.getContext('2d');
const clock=document.getElementById('clock'),energyUI=document.getElementById('energy'),hungerUI=document.getElementById('hunger'),message=document.getElementById('message');
const keys=new Set(),player={x:-180,z:80,energy:100,hunger:0,coins:40,seeds:8,harvest:0,vehicle:'foot',land:0},world={minute:420,day:1};
const plots=Array.from({length:12},(_,i)=>({x:-180+(i%4)*85,z:80+Math.floor(i/4)*80,planted:-1,watered:false}));
const saveKey='pixel-farm-seasons-v1';
function notice(s){message.textContent=s;}
function save(){try{localStorage.setItem(saveKey,JSON.stringify({player,world,plots,lastMealDay}));notice('Jogo salvo!');}catch{notice('Não foi possível salvar neste navegador.');}}
function load(){try{const s=JSON.parse(localStorage.getItem(saveKey)||'null');if(!s)return;Object.assign(player,s.player);Object.assign(world,s.world);s.plots?.forEach((p,i)=>{if(plots[i])Object.assign(plots[i],p)});lastMealDay=s.lastMealDay||0;notice('Jogo carregado!');}catch{notice('Save inválido: iniciando nova partida.');}}
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
const w=canvas.width,h=canvas.height,horizon=180;const hour=world.minute/60,night=hour>=19||hour<6;
ctx.fillStyle=night?'#172c48':'#8ec4e2';ctx.fillRect(0,0,w,horizon);
ctx.fillStyle=night?'#304c35':'#77ad58';ctx.fillRect(0,horizon,w,h-horizon);
ctx.fillStyle=night?'#293c30':'#547b43';ctx.beginPath();ctx.moveTo(w*.43,horizon);ctx.lineTo(w*.57,horizon);ctx.lineTo(w,540);ctx.lineTo(0,540);ctx.fill();
const offset=player.x*.7;
function building(x,y,width,height,color,roof){ctx.fillStyle=color;ctx.fillRect(x-offset,y,width,height);ctx.fillStyle=roof;ctx.beginPath();ctx.moveTo(x-offset-12,y);ctx.lineTo(x-offset+width/2,y-45);ctx.lineTo(x-offset+width+12,y);ctx.fill();}
building(115,205,185,130,'#e5c78b','#9e4c3c');building(320,245,150,90,'#c7b49a','#725044');
ctx.fillStyle='#315e35';for(let i=0;i<12;i++){let x=((i*127-player.x*.45)%1100+1100)%1100;ctx.fillRect(x,180,13,50);ctx.beginPath();ctx.arc(x+6,176,23,0,Math.PI*2);ctx.fill();}
for(const p of plots){const x=w/2+(p.x-player.x)*.75,y=330+(p.z-player.z)*.35;ctx.fillStyle='#6b4930';ctx.fillRect(x-21,y-12,42,24);if(p.planted>=0){ctx.fillStyle=p.watered?'#3eae46':'#a3bd56';ctx.fillRect(x-4,y-20,8,19);ctx.fillStyle='#8bda58';ctx.beginPath();ctx.arc(x,y-21,7,0,Math.PI*2);ctx.fill();}}
ctx.fillStyle='#265eaa';ctx.fillRect(356-offset,310,67,25);ctx.fillStyle='#262b2a';ctx.fillRect(365-offset,331,15,15);ctx.fillRect(402-offset,331,15,15);
ctx.fillStyle='#b53632';ctx.fillRect(445-offset,328,28,8);
ctx.fillStyle=player.vehicle==='fusca'?'#2257a3':player.vehicle==='bike'?'#b53632':'#3b332c';ctx.fillRect(w/2-13,375,26,80);ctx.fillStyle='#e7c7a0';ctx.beginPath();ctx.arc(w/2,359,20,0,Math.PI*2);ctx.fill();ctx.fillStyle='#476e9d';ctx.fillRect(w/2-22,382,44,45);
if(night){ctx.fillStyle='rgba(5,12,30,.24)';ctx.fillRect(0,0,w,h);ctx.fillStyle='#f7e6aa';ctx.beginPath();ctx.arc(830,78,25,0,Math.PI*2);ctx.fill();}else{ctx.fillStyle='#f7d876';ctx.beginPath();ctx.arc(830,78,30,0,Math.PI*2);ctx.fill();}
ctx.fillStyle='#f7f0dc';ctx.font='18px system-ui';ctx.fillText('Fazenda • F plantar | B comprar | V vender | T veículo | X expandir',18,35);
}
function frame(now){const dt=Math.min((now-last)/1000,.05);last=now;update(dt);render();requestAnimationFrame(frame);}requestAnimationFrame(frame);
load();
})();