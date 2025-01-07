local module = {}

-- 正常开发的项目在自动化部署的时候可以用脚本替换 DEBUG -> false
module.DEBUG = true

-- 启动测试用例的执行，默认应该是 false，通过命令修改其为 true，测试完毕再修改为 false（这意味着测试用例的运行环境必须是个沙盒，至少让崩溃后可以进入 __exit__ 逻辑）
module.TEST_ENABLED = true

-- 如何获取？好像有点困难
module.BASE_DIR = ""

return module
