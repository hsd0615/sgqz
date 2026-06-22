const fs=require("fs");
const db=JSON.parse(fs.readFileSync("/opt/data/sanguo.json","utf8"));
const lowQ=new Set(["proto_4_31","proto_4_32","proto_4_33","proto_4_34","proto_4_35","proto_4_36","proto_4_37","proto_4_39","proto_4_40","proto_4_41","proto_4_42","proto_4_43","proto_4_44","proto_4_45","proto_4_47","proto_4_48","proto_4_49","proto_4_50","proto_4_51","proto_4_52","proto_4_53","proto_4_55","proto_4_56","proto_4_57","proto_4_58","proto_4_59","proto_4_60","proto_4_61","proto_4_63","proto_4_64","proto_4_65","proto_4_66","proto_4_67","proto_4_68","proto_4_69","proto_4_71","proto_4_72","proto_4_73","proto_4_74","proto_4_75","proto_4_76","proto_4_95","proto_4_1","proto_4_10","proto_4_11","proto_4_12","proto_4_13","proto_4_14","proto_4_15","proto_4_16","proto_4_17","proto_4_18","proto_4_19","proto_4_2","proto_4_20","proto_4_21","proto_4_22","proto_4_23","proto_4_24","proto_4_25","proto_4_26","proto_4_27","proto_4_28","proto_4_29","proto_4_3","proto_4_30","proto_4_4","proto_4_5","proto_4_6","proto_4_7","proto_4_8","proto_4_9"]);
let bagRemoved=0,equipRemoved=0;
db.bagItems=db.bagItems.filter(b=>{if(!b.code||!b.code.startsWith("proto_4_"))return true;if(lowQ.has(b.code)){bagRemoved++;return false}return true});
db.generals.forEach(g=>{for(let s=1;s<=6;s++){const eq=g["equip"+s];if(eq&&eq!=="0"&&lowQ.has(eq)){g["equip"+s]="0";equipRemoved++}}});
fs.writeFileSync("/opt/data/sanguo.json",JSON.stringify(db));
console.log("背包移除:"+bagRemoved+"件, 武将卸下:"+equipRemoved+"件");
