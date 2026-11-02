(() => {
  const button = document.createElement('button');
  button.textContent = 'Enable sound';
  button.title = 'Desktop audio';
  Object.assign(button.style, {position:'fixed', bottom:'12px', right:'12px', zIndex:'99999', padding:'8px 12px', background:'#203b30', color:'white', border:'1px solid #91a995', borderRadius:'6px', cursor:'pointer'});
  document.body.appendChild(button);
  const volume = document.createElement('input');
  volume.type='range'; volume.min='0'; volume.max='100'; volume.value='100'; volume.title='Desktop volume'; volume.setAttribute('aria-label','Desktop volume');
  Object.assign(volume.style,{position:'fixed',bottom:'23px',right:'150px',zIndex:'99999',width:'90px'});
  document.body.appendChild(volume);
  let context, socket, node, gain, active = false;
  volume.addEventListener('input',()=>{if(gain)gain.gain.value=Number(volume.value)/100});
  const processor = `class DesktopAudio extends AudioWorkletProcessor {
    constructor(){super();this.q=[];this.pos=0;this.n=0;this.port.onmessage=e=>{let a=e.data;this.q.push(a);this.n+=a.length/2;while(this.n>24000 && this.q.length>1){let x=this.q.shift();this.n-=x.length/2-this.pos;this.pos=0}}}
    process(i,o){let out=o[0], l=out[0],r=out[1]||out[0];for(let j=0;j<l.length;j++){if(!this.q.length){l[j]=r[j]=0;continue}let a=this.q[0], k=Math.floor(this.pos)*2;l[j]=a[k]/32768;r[j]=a[k+1]/32768;this.pos+=48000/sampleRate;this.n-=48000/sampleRate; if(this.pos>=a.length/2){this.pos-=a.length/2;this.q.shift()}}return true}
  } registerProcessor('desktop-audio', DesktopAudio);`;
  async function close(){active=false;if(socket)socket.close();if(context)await context.close();socket=context=node=gain=null;button.textContent='Enable sound'}
  button.addEventListener('click', async () => {
    if(active){await close();return}
    try {
      context=new AudioContext(); await context.resume();
      const url=URL.createObjectURL(new Blob([processor],{type:'application/javascript'}));
      try {await context.audioWorklet.addModule(url)} finally {URL.revokeObjectURL(url)}
      node=new AudioWorkletNode(context,'desktop-audio',{outputChannelCount:[2]});gain=context.createGain();gain.gain.value=Number(volume.value)/100;node.connect(gain);gain.connect(context.destination);
      socket=new WebSocket(`${location.protocol === 'https:' ? 'wss:' : 'ws:'}//${location.host}/nodesktop/audio`);socket.binaryType='arraybuffer';active=true;
      button.textContent='Connecting audio…';
      socket.onopen=()=>button.textContent='Mute sound';
      socket.onmessage=e=>{if(e.data.byteLength%4===0)node.port.postMessage(new Int16Array(e.data))};
      socket.onclose=()=>{if(active){close();button.textContent='Retry audio'}};
      socket.onerror=()=>socket.close();
    } catch(e){await close();button.textContent='Audio unavailable'; console.error('Audio:',e)}
  });
})();
