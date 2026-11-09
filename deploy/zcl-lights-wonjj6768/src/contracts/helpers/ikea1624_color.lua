local R,a=require"contracts.helpers.ikea1624_xy",{}
function a.finite(d)
return type(d)=="number"and d==d and d>-math.huge and d<math.huge
end
function a.round(d,J)
local I=10 ^(J or 0)return math.floor(d*I+0.5)/I
end
function a.rgb_xy(red,green,blue,V,w)
if V then
local function v(d)
return d>0.04045 and((d+0.055)/1.055)^ 2.4 or d/12.92
end
red,green,blue=v(red),v(green),v(blue)end
local x,y,z=red*0.664511+green*0.154324+blue*0.162028,red*0.283881+green*0.668433+blue*0.047685,red*0.000088+green*0.07231+blue*0.986039


local K=x+y+z
if K==0 then return 0,0 end
if w==false then return x/K,y/K end
return a.round(x/K,4),a.round(y/K,4)
end
function a.hsv_xy(D,G,w)
local h,s=D/360,G/100
local i=math.floor(h*6)local f=h*6-i
local p,q,t=1-s,1-f*s,1-(1-f)*s
local T=({{1,t,p},{q,1,p},{p,1,t},{p,q,1},{t,p,1},{1,p,q}})[i%6+1]return a.rgb_xy(T[1],T[2],T[3],false,w)
end
function a.mired_xy(F)
if not a.finite(F)or F<=0 then return nil end
local P=a.round(1000000/F)local U=R.at(P)if U==nil then return nil end
return U[1],U[2]
end
function a.xy_mired(x,y)
local n=(x-0.332)/(0.1858-y)return 1000000/math.abs(437*n ^ 3+3601*n ^ 2+6861*n+5517)
end
function a.xy_hs(x,y)
local X,Z=x/y,(1-x-y)/y
local red,green,blue=X*1.656492-0.354851-Z*0.255038,-X*0.707196+1.655397+Z*0.036152,X*0.051713-0.121364+Z*1.01153


if red>blue and red>green and red>1 then
green,blue,red=green/red,blue/red,1
elseif green>blue and green>red and green>1 then
red,blue,green=red/green,blue/green,1
elseif blue>red and blue>green and blue>1 then
red,green,blue=red/blue,green/blue,1
end
if red~=red or red<0 then red=0 end
if green~=green or green<0 then green=0 end
if blue~=blue or blue<0 then blue=0 end
local k,E=math.max(red,green,blue),math.min(red,green,blue)local l,D=k-E,0
if k~=E then
if k==red then
D=(green-blue+l*(green<blue and 6 or 0))/(6*l)elseif k==green then
D=(blue-red+l*2)/(6*l)else
D=(red-green+l*4)/(6*l)end
end
return a.round(D*360),a.round(k==0 and 0 or l/k*100)
end
function a.sync(B,u,O)
if not O then return B end
local N,S,m=B.color or{},u.color or{},B.mode
if m==nil then m=u.mode end
if m==nil then
if B.mired~=nil then m=2 end
if B.color~=nil then m=N.hue~=nil and 0 or 1 end
end
local C,A,r,j=(S.x~=nil and S.y~=nil)or(N.x~=nil and N.y~=nil),(S.hue~=nil and S.saturation~=nil)or(N.hue~=nil and N.saturation~=nil),u.mired~=nil or B.mired~=nil,{mode=m,color={}}
local g=j.color
local function H(Q)
if N[Q]~=nil then return N[Q]end
return S[Q]
end
local function o(x,y)
local d=a.round(a.xy_mired(x,y))if not a.finite(d)then return nil end
if u.physical_min~=nil and d<u.physical_min then return u.physical_min end
if u.physical_max~=nil and d>u.physical_max then return u.physical_max end
return d
end
if m==0 then
g.hue,g.saturation=H"hue",H"saturation"if g.hue~=nil and g.saturation~=nil then
local x,y=a.hsv_xy(g.hue,g.saturation,false)if r then j.mired=o(x,y)end
if C then g.x,g.y=a.round(x,4),a.round(y,4)end
end
elseif m==1 then
g.x,g.y=H"x",H"y"if g.x~=nil and g.y~=nil then
if r then j.mired=o(g.x,g.y)end
if A then g.hue,g.saturation=a.xy_hs(g.x,g.y)end
end
elseif m==2 then
j.mired=B.mired~=nil and B.mired or u.mired
if j.mired~=nil then
local x,y=a.mired_xy(j.mired)if x~=nil then
if C then g.x,g.y=a.round(x,4),a.round(y,4)end
if A then g.hue,g.saturation=a.xy_hs(x,y)end
end
end
end
if next(g)==nil then j.color=nil end
return j
end
return a
