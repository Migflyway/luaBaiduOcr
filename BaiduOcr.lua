-- Author: FreeGame 【游自在】
-- FreeGame QQGroup:908536305


local bb = require("badboy")
bb.loadluasocket()
require 'bblibs.StrUtilsAPI'
require 'base64'

BaiduOcr =
{
	http = "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic";
	ak = nil;
	sk = nil;
	atk = nil;
}

function BaiduOcr.init(ak,sk)
	--setmetatable(BaiduOcr,OcrBase)
	BaiduOcr.ak = ak;
	BaiduOcr.sk = sk;
	BaiduOcr.getAccessToken(ak,sk);
end

function BaiduOcr.getAccessToken(ak,sk)
	local cacheBaiduOcrTime = getNumberConfig("baiduocr_Time",0);
	if mTime() - cacheBaiduOcrTime < 20* 86400000 then
		sysLog('use cache bdatk')
		local  cacheAtk = getStringConfig("baiduocr_Str","?");
		if cacheAtk ~= '?' then
			BaiduOcr.atk = cacheAtk;
			return;
		end
	end
	
	local atkhttp = 'http://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id='
	..ak..
	'&client_secret='
	..sk;
	
	sysLog(atkhttp)
	bb.loadluasocket()
	local http = bb.http
	local ltn12 = bb.ltn12
	
	local response_body = {}
	res, code = http.request(atkhttp)
	
	sysLog('获取atk 成功'..code)
	
	if code==200 then
		--		sysLog(res);
		local json = bb.getJSON()
		local obj =  json.decode(res);
		BaiduOcr.atk = obj.access_token;
		setStringConfig("baiduocr_Str",BaiduOcr.atk);
		setNumberConfig("baiduocr_Time",mTime());
	end
	
end


function BaiduOcr.getText(left,top,right,bottom)
	local snapFile = BaiduOcr.getPicture(left,top,right,bottom);
	--	local snapFile = "[public]ocr.png";
	local byteStr = BaiduOcr.getFileByteStr(snapFile);
	local json = bb.getJSON()
	local strutils = bb.getStrUtils()
	local httpParams = {};
	httpParams["url"] = BaiduOcr.http;
	httpParams["accessToken"] = BaiduOcr.atk;
	--httpParams["param"] = 'image='..urlEncode(byteStr);
	--httpParams["param"] = urlEncode(byteStr);
	--httpParams["param"] = 'image='..byteStr;
	httpParams["param"] = byteStr;
	
	localStr = json.encode(httpParams)
	--	sysLog(localStr)
	
	bb.loadluasocket()
	local http = bb.http
	local response_body = {}
	local res, code = http.request{
		url = 'http://192.168.56.1:8090/postjson',
		method = "POST",
		headers =
		{
			['Content-Type'] = 'application/json',
			['Content-Length'] = #localStr,
		},
		source = ltn12.source.string(localStr),
		sink = ltn12.sink.table(response_body)
	}
	
	
	res = table.concat(response_body)
	--sysLog(code..':'..response_body[1]);
	
	local resBody = json.decode(response_body[1])
	
	if resBody~=nil then
		return resBody.words_result;
	end
	
	return nil;
	
end


local function urlEncode(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end


function BaiduOcr.getPicture(left,top,right,bottom)
	local snapFile = "[public]ocr.png";
	
	ret = getScreenDirection()
	if ret == 0 then
		snapshot(snapFile, left,top,right,bottom);
	else
		snapshot(snapFile, left,top,right,bottom);
	end
	
	return snapFile;
	
end

function BaiduOcr.getFileByteStr(snapFile)
	sysLog('loading picture data ...')
	local f = io.open(snapFile,"rb")
	sysLog('readFile:'..mTime());
	local retbyte = f:read("*all")
	sysLog('readFileEnd:'..mTime());
	f:close()
	
	local base64Str = str2base64(retbyte);
	sysLog('readBase64End:'..mTime());
	return base64Str;
end

function str2base64(str)

    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''


    while #str > 0 do -- iterate through string
        local bytes_num = 0 -- number of shifted bytes
        local buf = 0 -- input buffer

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then -- if string not empty, shift 1st byte to buf
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end


        for group_cnt=1,(bytes_num+1) do
            b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end


        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end


    return s64
end