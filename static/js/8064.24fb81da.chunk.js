"use strict";(self.webpackChunkour_space=self.webpackChunkour_space||[]).push([[8064],{8064:(t,e,n)=>{n.d(e,{PolygonDrawer:()=>a});var o=n(7113);class a extends o.L{getCenter(t,e){return{x:-e/(t.sides/3.5),y:-e/.76}}getSidesData(t,e){const n=t.sides;return{count:{denominator:1,numerator:n},length:2.66*e/(n/3)}}}},7113:(t,e,n)=>{n.d(e,{L:()=>s});var o=n(4409);const a=0,r=0;class s{draw(t){const{particle:e,radius:n}=t;!function(t,e,n){const{context:s}=t,u=n.count.numerator*n.count.denominator,i=n.count.numerator/n.count.denominator,c=180*(i-2)/i,d=Math.PI-(0,o.pu)(c);if(s){s.beginPath(),s.translate(e.x,e.y),s.moveTo(a,r);for(let t=0;t<u;t++)s.lineTo(n.length,r),s.translate(n.length,r),s.rotate(d)}}(t,this.getCenter(e,n),this.getSidesData(e,n))}getSidesCount(t){var e;const n=t.shapeData;return Math.round((0,o.VG)(null!==(e=null===n||void 0===n?void 0:n.sides)&&void 0!==e?e:5))}}}}]);
//# sourceMappingURL=8064.24fb81da.chunk.js.map