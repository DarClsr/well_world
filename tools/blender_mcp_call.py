"""Run a local modeling script through the installed Blender MCP server."""
import asyncio
import os
import sys
from pathlib import Path

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def main():
    params = StdioServerParameters(
        command=str(Path.home() / '.local/bin/blender-mcp.exe'),
        env=dict(os.environ, DISABLE_TELEMETRY='true', BLENDER_HOST='127.0.0.1'),
    )
    async with stdio_client(params) as (reader, writer):
        async with ClientSession(reader, writer) as session:
            await session.initialize()
            result = await session.call_tool('execute_blender_code', {
                'code': Path(sys.argv[1]).read_text(encoding='utf-8'),
                'user_prompt': '\u8fd9\u4e2a\u6811\u6728 \u4f60\u53ef\u4ee5\u5efa\u6a21\u5417 \u6700\u597d\u53ef\u4ee5\u5728\u5f02\u4e16\u754c\u590d\u7528\u7684 \u591a\u79cd\u7c7b\u578b \u53c2\u8003\u56fe\u7247\u642d\u5efa\n\u5f02\u4e16\u754c\u6e38\u620f\u98ce\u683c\u54e6',
            })
            for part in result.content:
                if part.type == 'text':
                    print(part.text)
            if result.isError:
                raise SystemExit(1)


if __name__ == '__main__':
    asyncio.run(main())
