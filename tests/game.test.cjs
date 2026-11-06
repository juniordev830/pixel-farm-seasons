// Execute: node --test tests/game.test.cjs
const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const source=fs.readFileSync(require('node:path').join(__dirname,'../game.js'),'utf8');
function start(){
 const handlers={};const nodes={};
 const context2d={fillRect(){},beginPath(){},moveTo(){},lineTo(){},fill(){},arc(){},fillText(){}};
 for(const id of ['clock','energy','hunger','message','game'])nodes[id]={textContent:'',getContext:()=>context2d,width:960,height:540};
 const storage=new Map();let nextFrame;
 const sandbox={document:{getElementById:id=>nodes[id]},performance:{now:()=>0},requestAnimationFrame:cb=>{nextFrame=cb},addEventListener:(name,fn)=>{handlers[name]=fn},localStorage:{setItem:(k,v)=>storage.set(k,v),getItem:k=>storage.get(k)||null},Math,Number,String,Array,JSON};
 vm.runInNewContext(source,sandbox,{filename:'game.js'});
 const key=k=>handlers.keydown({key:k,repeat:false,preventDefault(){}});
 const frame=t=>{nextFrame(t)};
 return {key,frame,nodes,storage,handlers};
}
test('interface inicializa e relógio avança sem movimento',()=>{
 const s=start();s.frame(1000);assert.match(s.nodes.clock.textContent,/Dia 1/);assert.match(s.nodes.clock.textContent,/07:00/);
 for(let i=2;i<=40;i++)s.frame(i*1000);assert.match(s.nodes.clock.textContent,/07:04/);
});
test('compra de sementes desconta moedas',()=>{
 const s=start();s.key('b');s.frame(1000);assert.match(s.nodes.clock.textContent,/🪙 35/);assert.match(s.nodes.clock.textContent,/🌱 11/);
});
test('salvar e carregar restauram progresso',()=>{
 const s=start();s.key('b');s.key('p');assert.equal(s.storage.size,1);s.key('b');s.key('l');s.frame(1000);assert.match(s.nodes.clock.textContent,/🪙 35/);
});
test('plantio consome uma semente e rega',()=>{
 const s=start();s.key('f');s.frame(1000);assert.match(s.nodes.clock.textContent,/🌱 7/);s.key('f');assert.match(s.nodes.message.textContent,/regada/);
});
