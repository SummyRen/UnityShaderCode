﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shader入门精要/02高光反射光照模型/001.逐像素高光反射"{
	Properties{
		_Diffuse("Diffuse",COLOR)=(1,1,1,1)
		_Specular("Specular",COLOR)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
	}
	SubShader{
		Pass{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			//定义相应的变量
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal =normalize(i.worldNormal);

				fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				//reflect(i,n)函数:i是入射方向，n是法线方向，得到反射方向
				fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));
				//_WorldSpaceCameraPos得到世界空间中的摄像机位置
				//得到视角方向
				fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
				//计算高光反射，需要知道：1.入射光线颜色和强度信息；2.材质高光反射系数；3.视角方向；4.反射方向
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}

	FallBack "SPECULAR"
}