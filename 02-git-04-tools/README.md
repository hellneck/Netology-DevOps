# Домашнее задание к занятию «2.4. Инструменты Git»

## Вопрос №1
git show aefea

commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Update CHANGELOG.md

## Вопрос №2
git show 85024d3

tag: v0.12.23

## Вопрос №3
git show --pretty=raw b8d720

parent 56cd7859e05c36c06b56d013b55a252d0bb7e158
parent 9ea88f22fc6269854151c571162c5bcf958bee2b


## Вопрос №4
git log v0.12.23 v0.12.24

commit b14b74c4939dcab573326f4e3ee2a62e23e12f89
[Website] vmc provider links

commit 3f235065b9347a758efadc92295b540ee0a5e26e
Update CHANGELOG.md

commit 6ae64e247b332925b872447e9ce869657281c2bf
Fixes #24384

commit 5c619ca1baf2e21a155fcdb4c264cc9e24a2a353
website: Remove links to the getting started guide's old location
    
Since these links were in the soon-to-be-deprecated 0.11 language section, I
think we can just remove them without needing to find an equivalent link.

commit 06275647e2b53d97d4f0a19a0fec11f6d69820b5
Update CHANGELOG.md

commit d5f9411f5108260320064349b757f55c09bc4b80
command: Fix bug when using terraform login on Windows

commit 4b6d06cc5dcb78af637bbb19c198faff37a066ed
Update CHANGELOG.md

commit dd01a35078f040ca984cdd349f18d0b67e486c35
Update CHANGELOG.md

commit 225466bc3e5f35baa5d07197bbc079345b77525e
Cleanup after v0.12.23 release

## Вопрос №5
git log -S 'func providerSource'

commit 8c928e83589d90a031f811fae52a81be7153e82f

## Вопрос №6
git log -S globalPluginDirs

commit 8364383c359a6b738a436d1b7745ccdce178df47
commit c0b17610965450a89598da491ce9b6b5cbd6393f

## Вопрос №7
git log -S synchronizedWriters

Author: Martin Atkins <mart@degeneration.co.uk>
