
require 'BaiduOcr';

ret = getScreenDirection()

sysLog('屏幕朝向'..ret)

init("0", 0); --以当前应用 Home 键在右边初始化

--参数 百度OCR 项目中:(API Key,Secret Key)
--还是不知道参数在哪里？
BaiduOcr.init('','');

--获取屏幕某一个范围内的所有文字 参数:(左上角x,左上角,右下角x,右下角y)
local strs =  BaiduOcr.getText(585,199,700,237);

--返回值是个table
if strs~=nil then
	for k,v in pairs(strs) do
		sysLog(v.words);
	end
else
	sysLog('获取失败');
end
