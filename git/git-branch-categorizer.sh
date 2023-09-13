# 包含内容的远程分支
filter_contain='origin/*ID*'
local_filter_contain=${filter_contain/origin\//}
# 不包含内容的远程分支
filter_not_contain='origin/feat/*'
local_filter_not_contain=${filter_not_contain/origin\//}

echo "清理feat下的所有分支"
git branch | grep 'feat/' | xargs git branch -D

for branch in `git branch -r --list $filter_contain | grep -v $filter_not_contain`
do
    echo "正在检出分支 $branch"
    new_branch=${branch/origin\//}
    git checkout -b $new_branch $branch --
    echo "正在将分支 $branch 移动到 feat/$branch 中..."
    git branch -m $new_branch feat/$new_branch;
done

echo "切换到sit分支"
git checkout sit 

echo "分支移动完成，新的git分支如下："
git branch --list

echo "要清理远程分支吗？y or n: "
read clear_origin
case $clear_origin in 
    [Yy]|[Yy][Ee][Ss])
        for branch in `git branch -r --list $filter_contain | grep -v $filter_not_contain`
        do
            echo "正在清理分支 $branch"
            new_branch=${branch/origin\//}
            git push origin --delete $new_branch
        done
        ;;
    *)
        exit 0
        ;;
esac

echo "要新分支推送到远程仓库吗？y or n: "
read push_origin
case $push_origin in 
    [Yy]|[Yy][Ee][Ss])
        for branch in `git branch --list $local_filter_contain | grep -v $local_filter_not_contain`
        do 
            git push origin $branch
        done
        ;;
    *)
        exit 0
        ;;
esac
