#include "ANEUtils.h"
#include <sstream>

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <string>
#include <memory>
#include <stdio.h>
#include <assert.h>

LPCWSTR ANEUtils::stringToLPCWSTR(std::string orig)
{
	wchar_t *wcstring = 0;
	try
	{
		size_t origsize = orig.length() + 1;
		const size_t newsize = 100;
		size_t convertedChars = 0;
		if (orig == "")
		{
			wcstring = (wchar_t *)malloc(0);
			mbstowcs_s(&convertedChars, wcstring, origsize, orig.c_str(), _TRUNCATE);
		}
		else
		{
			wcstring = (wchar_t *)malloc(sizeof(wchar_t)*(orig.length() - 1));
			mbstowcs_s(&convertedChars, wcstring, origsize, orig.c_str(), _TRUNCATE);
		}
	}
	catch (std::exception e)
	{
	}
	return wcstring;
}

template<typename T> string toString(const T& t) {
	std::ostringstream oss;  //创建一个格式化输出流
	oss << t;             //把值传递如流中
	return oss.str();
}

std::string ANEUtils::getString(FREObject freObject) {
	uint32_t string1Length;
	const uint8_t *val;
	auto status = FREGetObjectAsUTF8(freObject, &string1Length, &val);

	if (isFREResultOK(status, "Could not convert UTF8."))
		return std::string(val, val + string1Length);
	return "";
}

uint32_t ANEUtils::getUInt32(FREObject freObject) {
	uint32_t result = 0;
	auto status = FREGetObjectAsUint32(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to uint32_t.");
	return result;
}

int32_t ANEUtils::getInt32(FREObject freObject) {
	int32_t result = 0;
	auto status = FREGetObjectAsInt32(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to int32_t.");
	return result;
}

double ANEUtils::getDouble(FREObject freObject) {
	auto result = 0.0;
	auto status = FREGetObjectAsDouble(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to double.");
	return result;
}


bool ANEUtils::getBool(FREObject freObject) {
	uint32_t result = 0;
	auto ret = false;
	FREGetObjectAsBool(freObject, &result);
	if (result > 0) ret = true;
	return ret;
}

bool ANEUtils::isFREResultOK(FREResult errorCode, std::string errorMessage) {
	if (FRE_OK == errorCode) return true;
	printf("isFREResultOK = %s", errorMessage.c_str());
	return false;
}
std::string ANEUtils::ws2s(const std::wstring &ws)
{
	size_t i;
	std::string curLocale = setlocale(LC_ALL, NULL);
	setlocale(LC_ALL, "chs");
	const wchar_t* _source = ws.c_str();
	size_t _dsize = 2 * ws.size() + 1;
	char* _dest = new char[_dsize];
	memset(_dest, 0x0, _dsize);
	wcstombs_s(&i, _dest, _dsize, _source, _dsize);
	std::string result = _dest;
	delete[] _dest;
	setlocale(LC_ALL, curLocale.c_str());
	return result;
}

std::wstring ANEUtils::s2ws(const std::string& s)
{
	int len;
	int slength = (int)s.length() + 1;
	len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
	wchar_t* buf = new wchar_t[len];
	MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
	std::wstring r(buf);
	delete[] buf;
	return r;

	std::vector<wchar_t> buff(s.size());
	std::locale loc("zh-CN");
	wchar_t* pwszNext = nullptr;
	const char* pszNext = nullptr;
	mbstate_t state = {};
	int res = std::use_facet<std::codecvt<wchar_t, char, mbstate_t> >
		(loc).in(state,
			s.data(), s.data() + s.size(), pszNext,
			buff.data(), buff.data() + buff.size(), pwszNext);

	if (std::codecvt_base::ok == res)
	{
		return std::wstring(buff.data(), pwszNext);
	}

	return NULL;
}



std::string ANEUtils::string_To_UTF8(const std::string & str)
{
	int nwLen = ::MultiByteToWideChar(CP_ACP, 0, str.c_str(), -1, NULL, 0);

	wchar_t * pwBuf = new wchar_t[nwLen + 1];//一定要加1，不然會出現尾巴
	ZeroMemory(pwBuf, nwLen * 2 + 2);

	::MultiByteToWideChar(CP_ACP, 0, str.c_str(), str.length(), pwBuf, nwLen);

	int nLen = ::WideCharToMultiByte(CP_UTF8, 0, pwBuf, -1, NULL, NULL, NULL, NULL);

	char * pBuf = new char[nLen + 1];
	ZeroMemory(pBuf, nLen + 1);

	::WideCharToMultiByte(CP_UTF8, 0, pwBuf, nwLen, pBuf, nLen, NULL, NULL);

	std::string retStr(pBuf);

	delete[]pwBuf;
	delete[]pBuf;

	pwBuf = NULL;
	pBuf = NULL;

	return retStr;
}

std::wstring ANEUtils::UTF82Wide(const std::string& strUTF8)
{
	int nWide = ::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), NULL, 0);

	std::unique_ptr<wchar_t[]> buffer(new wchar_t[nWide + 1]);
	if (!buffer)
	{
		return L"";
	}

	::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), buffer.get(), nWide);
	buffer[nWide] = L'\0';

	return buffer.get();
}



std::string ANEUtils::intToStdString(int value)
{
	std::stringstream str_stream;
	str_stream << value;
	std::string str = str_stream.str();

	return str;
}


FREObject ANEUtils::getFREObject(std::string value) {
	FREObject result;
	auto status = FRENewObjectFromUTF8(uint32_t(value.length()), reinterpret_cast<const uint8_t *>(value.data()), &result);
	return result;
}

FREObject ANEUtils::getFREObject(const char *value) {
	FREObject result;
	auto status = FRENewObjectFromUTF8(uint32_t(strlen(value)) + 1, reinterpret_cast<const uint8_t *>(value), &result);
	return result;
}

FREObject ANEUtils::getFREObject(double value) {
	FREObject result;
	auto status = FRENewObjectFromDouble(value, &result);
	return result;
}

FREObject ANEUtils::getFREObject(bool value) {
	FREObject result;
	auto status = FRENewObjectFromBool(value, &result);
	return result;
}

FREObject ANEUtils::getFREObject(int32_t value) {
	FREObject result;
	auto status = FRENewObjectFromInt32(value, &result);
	return result;
}

FREObject ANEUtils::getFREObject(uint32_t value) {
	FREObject result;
	auto status = FRENewObjectFromUint32(value, &result);
	return result;
}

FREObject ANEUtils::getFREObject(uint8_t value) {
	FREObject result;
	auto status = FRENewObjectFromUint32(value, &result);
	return result;
}
/*


*/

void ANEUtils::dispatchEvent(FREContext ctx, std::string name, std::string value) {
	FREDispatchStatusEventAsync(ctx, reinterpret_cast<const uint8_t *>(name.data()), reinterpret_cast<const uint8_t *>(value.data()));
}

void ANEUtils::setFREContext(FREContext ctx) {
	ctxContext = ctx;
}
void ANEUtils::trace(std::string message) const
{
	//dispatchEvent(ctxContext, "TRACE", message);
}




bool _ResizeWithMendBlack(uint8* pDst, uint8* pSrc, UINT uDstLen, UINT uSrcLen, const SIZE & dstSize, const SIZE & srcSize, UINT bpp)
{
	if (!pDst || !pSrc)
		return false;

	if (uDstLen == 0 || uDstLen != dstSize.cx * dstSize.cy * bpp)
		return false;

	if (uSrcLen == 0 || uSrcLen != srcSize.cx * srcSize.cy * bpp)
		return false;
	/*
	if(dstSize.cx < srcSize.cx)
	return false;

	if(dstSize.cy < srcSize.cy)
	return false;*/

	UINT dstLineblockSize = dstSize.cx * bpp;
	UINT srcLineblockSize = srcSize.cx * bpp;

	int mendCxLeftEnd = dstSize.cx > srcSize.cx ? (dstSize.cx - srcSize.cx) / 2 : 0;
	int mendCyToEnd = dstSize.cy > srcSize.cy ? (dstSize.cy - srcSize.cy) / 2 : 0;

	for (int y = 0; y < dstSize.cy; y++)
	{
		if (y >= mendCyToEnd && y < mendCyToEnd + srcSize.cy)
		{
			if (mendCxLeftEnd > 0)
				memcpy(pDst + (bpp * mendCxLeftEnd), pSrc, srcLineblockSize);
			else
				memcpy(pDst, pSrc, srcLineblockSize);
			pSrc += srcLineblockSize;
		}
		pDst += dstLineblockSize;
	}
	return true;
}
bool Convert24Image(BYTE *p32Img, BYTE *p24Img, DWORD dwSize32)
{

	if (p32Img != NULL && p24Img != NULL && dwSize32>0)
	{

		DWORD dwSize;

		dwSize = dwSize32 / 4;

		BYTE *pTemp, *ptr;

		pTemp = p32Img;
		ptr = p24Img;

		int ival = 0;
		for (DWORD index = 0; index < dwSize; index++)
		{
			unsigned char r = *(pTemp++);
			unsigned char g = *(pTemp++);
			unsigned char b = *(pTemp++);
			(pTemp++);//skip alpha

			*(ptr++) = r;
			*(ptr++) = g;
			*(ptr++) = b;
		}
	}
	else
	{
		return false;
	}

	return true;
}