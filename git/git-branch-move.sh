move_branchs=("auth-holder-sit" "pos-code" "qrcode-sit" "sit-refactor")
move_to="refactor/"

echo "切换到sit分支..."
git checkout sit

echo "清理工作..."
for branch in "${move_branchs[@]}"
do
    echo "删除分支  $branch, $move_to$branch"
    # 清理原始分支
    if git rev-parse --verify $branch > /dev/null 2>&1; then
        echo "删除分支 $branch ..."
        git branch -D $branch
    fi
    # 清理重命名之后的分支
    if git rev-parse --verify $move_to$branch > /dev/null 2>&1; then
        echo "删除分支 $move_to$branch ..."
        git branch -D $move_to$branch
    fi
done

clear_flag=false
push_flag=false

read -p "移动后是否要推送到远程分支吗？y or n: " push_origin
# 将用户输入转换为小写
push_origin=${push_origin,,}
if [[ "$push_origin" == "y" || "$push_origin" == "yes" ]]; then
    push_flag=true
else 
    push_flag=false
fi

read -p "是否要清理移动前的远程分支吗？y or n: " clear_origin

# 将用户输入转换为小写
clear_origin=${clear_origin,,}
if [[ "$clear_origin" == "y" || "$clear_origin" == "yes" ]]; then
    clear_flag=true
else 
    clear_flag=false
fi

for branch in "${move_branchs[@]}"
do 
    echo "正在检出分支 $branch ..."
    git checkout -B $branch origin/$branch &
    wait
done

for branch in "${move_branchs[@]}"
do 
    new_branch_name="$move_to$branch"
    echo "正在进行分支重命名，原始：$branch, 目标：$new_branch_name"
    git branch -m $branch $new_branch_name &
done
wait

for branch in "${move_branchs[@]}"
do 
    if [ $push_flag ]; then
        echo "正在将新分支 $new_branch_name 推送到远程..."
        git push origin $new_branch_name &
        wait
    fi
    
    if [ $clear_flag ]; then 
        echo "正在清理远程分支 $branch ..."
        new_branch=${branch/origin\//}
        git push origin --delete $new_branch &
        wait
    fi
done
