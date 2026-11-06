'use strict';
(() => {
const canvas=document.getElementById('game'),ctx=canvas.getContext('2d');
const clock=document.getElementById('clock'),energyUI=document.getElementById('energy'),hungerUI=document.getElementById('hunger'),message=document.getElementById('message');
const keys=new Set(),player={x:0,z:0,energy:100,hunger:0},world={minute:420,day:1};
let last=performance.now(),lastMealDay=0,mealWarningDay=0;
const clamp=(n,min,max)=>Math.max(min,Math.min(max,n));
function eat(){player.hunger=clamp(player.hunger-65,0,100);player.energy=clamp(player.energy+12,0,100);lastMealDay=world.day;message.textContent='Almoço feito! Energia recuperada.';}
addEventListener('keydown',e=>{const k=e.key.toLowerCase();if(['arrowup','arrowdown','arrowleft','arrowright',' '].includes(k))e.preventDefault();keys.add(k);if(!e.repeat&&k==='e')eat();if(!e.repeat&&k==='r'){player.energy=clamp(player.energy+25,0,100);message.textContent='Você descansou um pouco.';}});
addEventListener('keyup',e=>keys.delete(e.key.toLowerCase()));
addEventListener('blur',()=>keys.clear());
function update(dt){
world.minute+=dt*2;while(world.minute>=1440){world.minute-=1440;world.day++;lastMealDay=0;}
const hour=world.minute/60;
player.hunger=clamp(player.hunger+dt*.12,0,100);
if(hour>=12&&lastMealDay!==world.day){player.hunger=clamp(player.hunger+dt*.25,0,100);player.energy=clamp(player.energy-dt*.18,0,100);if(mealWarningDay!==world.day){message.textContent='Eita, já passou da hora de almoçar!';mealWarningDay=world.day;}}
if(hour>=22||hour<5)player.energy=clamp(player.energy-dt*.24,0,100);
let dx=Number(keys.has('d')||keys.has('arrowright'))-Number(keys.has('a')||keys.has('arrowleft'));
let dz=Number(keys.has('w')||keys.has('arrowup'))-Number(keys.has('s')||keys.has('arrowdown'));
const len=Math.hypot(dx,dz)||1,speed=player.energy<25?22:55;
player.x=clamp(player.x+dx/len*speed*dt,-400,400);player.z=clamp(player.z+dz/len*speed*dt,-400,400);
clock.textContent='Dia '+world.day+' · '+String(Math.floor(world.minute/60)).padStart(2,'0')+':'+String(Math.floor(world.minute%60)).padStart(2,'0');
energyUI.textContent='Energia: '+Math.round(player.energy);hungerUI.textContent='Fome: '+Math.round(player.hunger);
}
function render(){
const w=canvas.width,h=canvas.height,horizon=180;
ctx.fillStyle='#8ec4e2';ctx.fillRect(0,0,w,horizon);
ctx.fillStyle='#77ad58';ctx.fillRect(0,horizon,w,h-horizon);
ctx.fillStyle='#547b43';ctx.beginPath();ctx.moveTo(w*.43,horizon);ctx.lineTo(w*.57,horizon);ctx.lineTo(w,540);ctx.lineTo(0,540);ctx.fill();
const offset=player.x*.7;
function building(x,y,width,height,color,roof){ctx.fillStyle=color;ctx.fillRect(x-offset,y,width,height);ctx.fillStyle=roof;ctx.beginPath();ctx.moveTo(x-offset-12,y);ctx.lineTo(x-offset+width/2,y-45);ctx.lineTo(x-offset+width+12,y);ctx.fill();}
building(115,205,185,130,'#e5c78b','#9e4c3c');building(320,245,150,90,'#c7b49a','#725044');
ctx.fillStyle='#315e35';for(let i=0;i<12;i++){let x=((i*127-player.x*.45)%1100+1100)%1100;ctx.fillRect(x,180,13,50);ctx.beginPath();ctx.arc(x+6,176,23,0,Math.PI*2);ctx.fill();}
ctx.fillStyle='#265eaa';ctx.fillRect(356-offset,310,67,25);ctx.fillStyle='#262b2a';ctx.fillRect(365-offset,331,15,15);ctx.fillRect(402-offset,331,15,15);
ctx.fillStyle='#b53632';ctx.fillRect(445-offset,328,28,8);
ctx.fillStyle='#3b332c';ctx.fillRect(w/2-13,375,26,80);ctx.fillStyle='#e7c7a0';ctx.beginPath();ctx.arc(w/2,359,20,0,Math.PI*2);ctx.fill();ctx.fillStyle='#476e9d';ctx.fillRect(w/2-22,382,44,45);
ctx.fillStyle='#f7f0dc';ctx.font='18px system-ui';ctx.fillText('Fazenda • protótipo 2D de câmera acompanhando o personagem',18,35);
}
function frame(now){const dt=Math.min((now-last)/1000,.05);last=now;update(dt);render();requestAnimationFrame(frame);}requestAnimationFrame(frame);
})();