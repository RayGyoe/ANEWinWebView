#pragma once
#include "FlashRuntimeExtensions.h"

#include <string>
#include <windows.h>
using std::string;

#include <map>
#include <vector>
#include <string>

typedef signed char			int8;
typedef signed short		int16;
typedef signed int			int32;
typedef signed long long	int64;
typedef unsigned char		uint8;
typedef unsigned short		uint16;
typedef unsigned int		uint32;
typedef unsigned long long	uint64;

#ifndef SafeDelete
#define SafeDelete(p) { delete (p); (p) = NULL; }
#endif //SafeDelete

#define SafeDeleteVideoArr(pArr) {delete[] pArr; pArr = 0;}

bool _ResizeWithMendBlack(uint8* pDst, uint8* pSrc, UINT uDstLen, UINT uSrcLen, const SIZE & dstSize, const SIZE & srcSize, UINT bpp);
bool Convert24Image(BYTE *p32Img, BYTE *p24Img, DWORD dwSize32);



class ANEUtils {

public:
	FREObject getFREObject(std::string value);
	FREObject getFREObject(const char *value);
	FREObject getFREObject(double value);
	FREObject getFREObject(bool value);
	FREObject getFREObject(int32_t value);
	FREObject getFREObject(uint32_t value);
	FREObject getFREObject(uint8_t value);
	
	LPCWSTR ANEUtils::stringToLPCWSTR(std::string orig);

	std::string intToStdString(int value);

	uint32_t getUInt32(FREObject freObject);
	int32_t getInt32(FREObject freObject);
	std::string getString(FREObject freObject);
	bool getBool(FREObject freObject);
	double getDouble(FREObject freObject);

	std::string string_To_UTF8(const std::string & str);
	std::wstring ANEUtils::UTF82Wide(const std::string& strUTF8);
	std::string ANEUtils::ws2s(const std::wstring &ws);

	std::wstring s2ws(const std::string & s);

	FREObject newBool(bool value);

	void ANEUtils::dispatchEvent(std::string name, std::string value);
	void trace(std::string message);


	void setFREContext(FREContext ctx);
	FREContext ctxContext;



private:
	bool isFREResultOK(FREResult errorCode, std::string errorMessage);
};