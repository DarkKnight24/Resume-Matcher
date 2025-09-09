import os
import logging
import json
import requests

from typing import Any, Dict
from fastapi.concurrency import run_in_threadpool

from ..exceptions import ProviderError
from .base import Provider, EmbeddingProvider
from ...core import settings

logger = logging.getLogger(__name__)


class OpenAIProvider(Provider):
    def __init__(self, api_key: str | None = None, model_name: str = settings.LL_MODEL,api_base_url: str | None = "https://api.openai.com/v1",
                 opts: Dict[str, Any] = None):
        if opts is None:
            opts = {}
        api_key = api_key or settings.LLM_API_KEY or os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ProviderError("OpenAI API key is missing")
        self._api_key = api_key
        self._api_base_url = api_base_url
        self.model = model_name
        self.opts = opts
        self.instructions = ""

    def _generate_sync(self, prompt: str, options: Dict[str, Any]) -> str:
        try:
            # 构建请求头
            headers = {
                "Authorization": f"Bearer {self._api_key}",
                "Content-Type": "application/json"
            }
            
            # 构建请求体
            payload = {
                "model": self.model,
                "stream": False,
                "messages": [
                    {
                        'role': 'system',
                        'content': prompt
                    }
                ]
            }
            
            # 添加额外选项
            payload.update(options)
            
            # 发送请求
            url = f"{self._api_base_url}/chat/completions"
            response = requests.post(url, headers=headers, json=payload)
            response.raise_for_status()
            
            # 解析响应
            response_data = response.json()
            logger.debug(f"使用 'content' 字段成功调用 OpenAI API")
            return response_data["choices"][0]["message"]["content"]
                
        except Exception as e:
            raise ProviderError(f"OpenAI - error generating response: {e}") from e

    async def __call__(self, prompt: str, **generation_args: Any) -> str:
        if generation_args:
            logger.warning(f"OpenAIProvider - generation_args not used {generation_args}")
        myopts = {
            "temperature": self.opts.get("temperature", 0),
            "top_p": self.opts.get("top_p", 0.9),
# top_k not currently supported by any OpenAI model - https://community.openai.com/t/does-openai-have-a-top-k-parameter/612410
#            "top_k": generation_args.get("top_k", 40),
# neither max_tokens
#            "max_tokens": generation_args.get("max_length", 20000),
        }
        return await run_in_threadpool(self._generate_sync, prompt, myopts)


class OpenAIEmbeddingProvider(EmbeddingProvider):
    def __init__(
        self,
        api_key: str | None = None,
        api_base_url: str | None = "https://api.openai.com/v1",
        embedding_model: str = settings.EMBEDDING_MODEL,
    ):
        api_key = api_key or settings.EMBEDDING_API_KEY or os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ProviderError("OpenAI API key is missing")
        self._api_key = api_key
        self._api_base_url = api_base_url
        self._model = embedding_model

    async def embed(self, text: str) -> list[float]:
        try:
            def _embed_sync():
                # 构建请求头
                headers = {
                    "Authorization": f"Bearer {self._api_key}",
                    "Content-Type": "application/json"
                }
                
                # 构建请求体
                payload = {
                    "input": text,
                    "model": self._model
                }
                
                # 发送请求
                url = f"{self._api_base_url}/embeddings"
                response = requests.post(url, headers=headers, json=payload)
                response.raise_for_status()
                
                # 解析响应
                response_data = response.json()
                return response_data["data"][0]["embedding"]
            
            return await run_in_threadpool(_embed_sync)
        except Exception as e:
            raise ProviderError(f"OpenAI - error generating embedding: {e}") from e
