"use strict";(self.webpackChunkreact_native_reanimated_docs=self.webpackChunkreact_native_reanimated_docs||[]).push([[2547],{347:(e,t,n)=>{n.d(t,{D:()=>o});var r=n(76933);const o=function(e){let t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:2,n=arguments.length>2&&void 0!==arguments[2]&&arguments[2],o=arguments.length>3?arguments[3]:void 0,i=arguments.length>4?arguments[4]:void 0;return(0,r.oF)(e,(()=>{const a="function"==typeof e?e():e;return{isHigherOrder:!0,onFrame:function(e,r){const o=a.onFrame(a,r);if(e.current=a.current,o){if(e.reps+=1,a.callback&&a.callback(!0,e.current),e.reduceMotion||t>0&&e.reps>=t)return!0;const o=n?a.current:e.startValue;return n&&(a.toValue=e.startValue,e.startValue=o),a.onStart(a,o,r,a.previousAnimation),!1}return!1},onStart:function(e,r,o,i){e.startValue=r,e.reps=0,void 0===a.reduceMotion&&(a.reduceMotion=e.reduceMotion),e.reduceMotion&&n&&(t<=0||t%2==0)?(e.current=e.startValue,e.onFrame=()=>!0):a.onStart(a,r,o,i)},reps:0,current:a.current,callback:e=>{o&&o(e),!e&&a.callback&&a.callback(!1)},startValue:0,reduceMotion:(0,r.uh)(i)}}))}},49638:(e,t,n)=>{n.d(t,{n:()=>i});var r=n(67177),o=n(34605);n(67294);const i=(0,o.Z)(r.Z)},35842:(e,t,n)=>{n.d(t,{l:()=>p});var r=n(67294),o=n(96085),i=n(97604),a=n(49402),c=n(76933),s=n(58095),l=n(10758),u=n(40093),f=n(41956),d=n(83442);function m(e,t,n,r){if(Array.isArray(t)&&t.forEach(((t,o)=>{m(e,t,n&&n[o],r&&r[o])})),"object"==typeof t&&t.onFrame){const o=t;let i=o.current;void 0!==r&&("object"==typeof r?void 0!==r.value?i=r.value:void 0!==r.onFrame&&(void 0!==(null==n?void 0:n.current)?i=n.current:void 0!==(null==r?void 0:r.current)&&(i=r.current)):i=r),o.callStart=e=>{o.onStart(o,i,e,n)},o.callStart(e),o.callStart=null}else"object"==typeof t&&Object.keys(t).forEach((o=>m(e,t[o],n&&n[o],r&&r[o])))}function v(e,t,n,r,o){if(!o.value)return!0;if(Array.isArray(e)){r[n]=[];let i=!0;return e.forEach(((e,a)=>{v(e,t,a,r[n],o)||(i=!1)})),i}if("object"==typeof e&&e.onFrame){let o=!0;return e.finished||(e.callStart&&(e.callStart(t),e.callStart=null),o=e.onFrame(e,t),e.timestamp=t,o&&(e.finished=!0,e.callback&&e.callback(!0))),r[n]=e.current,o}if("object"==typeof e){r[n]={};let i=!0;return Object.keys(e).forEach((a=>{v(e[a],t,a,r[n],o)||(i=!1)})),i}return r[n]=e,!0}function h(e,t){if(Array.isArray(e))for(const n of e)h(n,t);else if("object"==typeof e&&null!==e&&void 0===e.value)for(const n of Object.keys(e))h(e[n],n);else if(void 0!==t&&"object"==typeof e&&null!==e&&void 0!==e.value)throw new Error(`[Reanimated] Invalid value passed to \`${t}\`, maybe you forgot to use \`.value\`?`)}const p=function(e,t,p){let y=arguments.length>3&&void 0!==arguments[3]&&arguments[3];const b=(0,f.S)(),A=(0,r.useRef)();let g=Object.values(e.__closure??{});var w;(0,d.Wr)()&&(!g.length&&null!==(w=t)&&void 0!==w&&w.length&&(g=t));const k=p?Array.isArray(p)?p:[p]:[],j=p?(0,u.Nq)(k):null,_=(0,l.y)(!0),R=(0,r.useRef)({});if(t?t.push(e.__workletHash):t=[...g,e.__workletHash],j&&t.push(j),!A.current){const t=(0,c.AX)(e);(0,u.Dl)(t),A.current={initial:{value:t,updater:e},remoteState:(0,o.I1)({last:t,animations:{},isAnimationCancelled:!1,isAnimationRunning:!1}),viewDescriptors:(0,f.G)()}}const{initial:E,remoteState:S,viewDescriptors:O}=A.current,D=O.sharableViewDescriptors,F=s.Z.native?void 0:b;return t.push(D),(0,r.useEffect)((()=>{let t,r=e;p&&(r=()=>{const t=e();return k.forEach((e=>{e(t)})),t}),t=(0,d.V5)()?()=>{!function(e,t,r,o,i,c){let s=arguments.length>6&&void 0!==arguments[6]?arguments[6]:[];const l=r.animations??{},f=t()??{},d=r.last;let h,p=!1;Object.keys(l).forEach((e=>{const t=f[e];(0,u.mE)(t)||delete l[e]})),Object.keys(f).forEach((e=>{const t=f[e];(0,u.mE)(t)&&(h=n.g.__frameTimestamp||performance.now(),m(h,t,l[e],d[e]),l[e]=t,p=!0)})),p?(r.animations=l,r.isAnimationRunning||(r.isAnimationCancelled=!1,r.isAnimationRunning=!0,function t(n){const{animations:l,last:u,isAnimationCancelled:f}=r;if(f)return void(r.isAnimationRunning=!1);const d={};let m=!0;Object.keys(l).forEach((e=>{v(l[e],n,e,d,i)?(u[e]=d[e],delete l[e]):m=!1})),Object.keys(d).length&&(0,a.R)(e,d,o,c,s),m?r.isAnimationRunning=!1:requestAnimationFrame(t)}(h))):(r.isAnimationCancelled=!0,r.animations=[]),r.last=f,(0,u.wU)(d,f)||(0,a.R)(e,f,o,c,s)}(D,e,S,F,_,R,k)}:()=>{!function(e,t,r,o,i){let c=arguments.length>5&&void 0!==arguments[5]&&arguments[5];const s=r.animations??{},l=t()??{},f=r.last,d={};let h,p=!1,y=!1;for(const a in l){const e=l[a];(0,u.mE)(e)?(h=n.g.__frameTimestamp||performance.now(),m(h,e,s[a],f[a]),s[a]=e,p=!0):(y=!0,d[a]=e,delete s[a])}if(p){const t=n=>{const{animations:c,last:s,isAnimationCancelled:l}=r;if(l)return void(r.isAnimationRunning=!1);const u={};let f=!0;for(const e in c)v(c[e],n,e,u,i)?(s[e]=u[e],delete c[e]):f=!1;u&&(0,a.Z)(e,u,o),f?r.isAnimationRunning=!1:requestAnimationFrame(t)};r.animations=s,r.isAnimationRunning||(r.isAnimationCancelled=!1,r.isAnimationRunning=!0,t(h)),y&&(0,a.Z)(e,d,o)}else r.isAnimationCancelled=!0,r.animations=[],(0,u.wU)(f,l)||(0,a.Z)(e,l,o,c);r.last=l}(D,r,S,F,_,y)};const o=(0,i.R)(t,g);return()=>{(0,i.B)(o)}}),t),(0,r.useEffect)((()=>(_.value=!0,()=>{_.value=!1})),[]),h(E.value),(0,d.V5)()?{viewDescriptors:O,initial:E,viewsRef:b,animatedStyle:R}:{viewDescriptors:O,initial:E,viewsRef:b}}},40093:(e,t,n)=>{n.d(t,{Ak:()=>s,Dl:()=>d,Nq:()=>l,mE:()=>u,wU:()=>f,zX:()=>c});var r=n(67294),o=n(96085),i=n(83442),a=n(18452);const c=function(e){let t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:[],n=arguments.length>2&&void 0!==arguments[2]&&arguments[2];const o=(0,r.useRef)(null);return null===o.current?o.current=new a.Z(e,t):n&&o.current.updateWorklet(e),o},s=function(e,t){const n=(0,r.useRef)(null);null===n.current&&(n.current={context:(0,o.I1)({}),savedDependencies:[]}),(0,r.useEffect)((()=>()=>{n.current=null}),[]);const{context:a,savedDependencies:c}=n.current;t=function(e,t){const n=Object.values(t).filter((e=>void 0!==e));e?e.push(l(n)):e=n.map((e=>({workletHash:e.__workletHash,closure:e.__closure})));return e}(t,e);const s=!function(e,t){function n(e,t){return e===t&&(0!==e||1/e==1/t)||e!=e&&t!=t}const r="function"==typeof Object.is?Object.is:n;function o(e,t){if(!e||!t||t.length!==e.length)return!1;for(let n=0;n<t.length;++n)if(!r(e[n],t[n]))return!1;return!0}return o(e,t)}(t,c);n.current.savedDependencies=t;return{context:a,doDependenciesDiffer:s,useWeb:(0,i.$L)()||(0,i.V5)()}};function l(e){return Object.values(e).reduce(((e,t)=>e+t.__workletHash.toString()),"")}function u(e){return Array.isArray(e)?e.some(u):"object"==typeof e&&null!==e&&(void 0!==e.onFrame||Object.values(e).some(u))}function f(e,t){const n=Object.keys(e),r=Object.keys(t);if(n.length!==r.length)return!1;for(let o=0;o<n.length;o++)if(e[n[o]]!==t[n[o]])return!1;return!0}const d=e=>{if("object"!=typeof e)throw new Error(`[Reanimated] \`useAnimatedStyle\` has to return an object, found ${typeof e} instead.`);if(Array.isArray(e))throw new Error("[Reanimated] `useAnimatedStyle` has to return an object and cannot return static styles combined with dynamic ones. Please do merging where a component receives props.")}}}]);