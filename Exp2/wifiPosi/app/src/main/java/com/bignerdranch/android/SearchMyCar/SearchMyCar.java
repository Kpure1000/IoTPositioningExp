package com.bignerdranch.android.beaconlocation;

import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class SearchMyCar extends AppCompatActivity implements View.OnTouchListener{

    //保存屏幕点击点的位置
    private static int xSearch;
    private static int ySearch;
    private int j = 1;

    //设置为屏幕上方的提示
    private int x;
    private int y;
    //点击定位的位置
    private static int x_tmp;
    private static int y_tmp;

    //根据指数衰减模型建立
    private final int power= 45;             //1m时信号强度
    private final double n = 3.5;        //环境衰减因子

    private TextView endRotate;
    private LinearLayout ll;
    private RelativeLayout.LayoutParams mParams;
    private RelativeLayout relativeLayout;
    private RelativeLayout loc_relativeLayout;
    private RelativeLayout.LayoutParams loc_params;
    private ArrayList<ImageView>mImageView = new ArrayList<ImageView>(){};

    private TreeSet<Point> mSet = new TreeSet<Point>(new Comparator<Point>() {
        @Override
        public int compare(Point o1, Point o2) {
            return Integer.valueOf(o1.getRssi()).compareTo(Integer.valueOf(o2.getRssi()));
        }
    });
    //private int x,y;//________________________________________________________替换为全局变量

    private ArrayList<Point> mPointArrayList = new ArrayList<Point>();

    //private final static int SEARCH_CODE = 0x123;
    private BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    private static final String TAG = "SearchMyCar";
    private Button mScanButton;
    private Button mSearchButton;

    private List<BluetoothDevice> mBlueList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_page);

        relativeLayout = (RelativeLayout)findViewById(R.id.search_relative);
        mImageView.add(0, new ImageView(SearchMyCar.this));

        mImageView.get(0).setImageResource(R.drawable.photo);
        //设置相对布局（控件）的大小
        mParams = new RelativeLayout.LayoutParams(100,100);
        mParams.setMargins(0, 1290, 0, 0);
        mImageView.get(0).setLayoutParams(mParams);
        relativeLayout.addView(mImageView.get(0));
        endRotate = (TextView)findViewById(R.id.end_zuobiao);
        //endRotate.setText("当前位置：（"+0+"cm,"+0+"cm），RSSI="+rssiSearch);

        ll = (LinearLayout)findViewById(R.id.touch);
        ll.setOnTouchListener(this);


        mScanButton = (Button)findViewById(R.id.scan);
        mSearchButton = (Button)findViewById(R.id.find);
        mSearchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                result();
            }
        });
        mScanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startScanBluth();
            }
        });
        init();
    }

    /**
     * 判断蓝牙是否开启
     */
    private void init() {
        startDiscovery();
    }

    public void result(){
        if(!mSet.isEmpty()){
            mSet.pollLast();
        }
        if(!mPointArrayList.isEmpty()){
            mPointArrayList.clear();
        }
        for(int i = 0;i<10;i++){
            if(!mSet.isEmpty()){
                Point t = mSet.pollLast();
                mPointArrayList.add(t);
            }
        }
        car_loc();
        mSet.clear();
    }

    public void car_loc(){//显示位置
        for(int i = 0;i<mPointArrayList.size();i++){
            //获取当前位置信息，进行地图位置校正
            x_tmp = mPointArrayList.get(i).getX();
            y_tmp = mPointArrayList.get(i).getY();
            //重新计算自身定位
            double a=p0_x-p2_x;
            double b=p0_y-p2_y;
            double c= Math.pow(p0_x, 2) - Math.pow(p2_x, 2) + Math.pow(p0_y, 2) - Math.pow(p2_y, 2) + Math.pow(x_tmp, 2) - Math.pow(y_tmp, 2);
            double d=p1_x-p2_x;
            double e=p1_y-p2_y;
            double f=Math.pow(p1_x, 2) - Math.pow(p2_x, 2) + Math.pow(p1_y, 2) - Math.pow(p2_y, 2) + Math.pow(x_tmp, 2) - Math.pow(y_tmp, 2);
            aim_x=(int)((b*f-e*c)/(2*b*d-2*a*e));
            aim_y=(int)((a*f-d*c)/(2*a*e-2*b*d));
            //根据多次不同地点计算结果进行显示
            String string=String.valueOf(aim_x).substring(0,5)+","+String.valueOf(aim_y).substring(0,5);
            loc_relativeLayout = (RelativeLayout)findViewById(R.id.loc_relative);
            mImageView.add(1,new ImageView(SearchMyCar.this));
            mImageView.get(1).setImageResource(R.drawable.circle);
            loc_params = new RelativeLayout.LayoutParams(60,60);
            loc_params.setMargins(aim_x, aim_y, 0, 0);
            mImageView.get(1).setLayoutParams(loc_params);
            loc_relativeLayout.addView(mImageView.get(1));
        }
    }
    /**
     * 注册异步搜索蓝牙设备的广播
     */
    private void startDiscovery() {
        // 找到设备的广播
        IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        // 注册广播
        registerReceiver(searchReceiver, filter);
        // 搜索完成的广播
        IntentFilter filter1 = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        // 注册广播
        registerReceiver(searchReceiver, filter1);
        startScanBluth();
    }

    private double calDis(int rssi){
        int iRssi = Math.abs(rssi);//标准话RSSI值
        double Power = (iRssi-power)/(10*n); //进行距离计算
        return Math.pow(10,Power);
    }

    //搜索所有蓝牙的广播接收器
    private final BroadcastReceiver searchReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // 收到的广播类型
            String action = intent.getAction();
            // 发现设备的广播
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                // 从intent中获取设备
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                int RSSI = intent.getExtras().getShort( BluetoothDevice.EXTRA_RSSI);

                if (device.getAddress().equals(BluetoothList.MAC)){
                    mBluetoothAdapter.cancelDiscovery();
                    //播报显示距离
                    Toast.makeText(context,"扫描成功,RSSI："+Integer.toString(RSSI)+"距离您："+String.format("%.2f",calDis(RSSI))+"米",Toast.LENGTH_SHORT).show();
                    Point tmp = new Point(xSearch,ySearch);//x,y要用静态变量
                    tmp.setRssi(RSSI);
                    mSet.add(tmp);
                }
                // 搜索完成
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                // 关闭进度条
                    progressDialog.dismiss();
            }
        }
    };

    private ProgressDialog progressDialog;

    /**
     * 搜索蓝牙的方法
     */
    private void startScanBluth() {
        // 判断是否在搜索,如果在搜索，就取消搜索
        if (mBluetoothAdapter.isDiscovering()) {
            mBluetoothAdapter.cancelDiscovery();
        }
        // 开始搜索
        mBluetoothAdapter.startDiscovery();
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(this);
        }
        progressDialog.setMessage("正在搜索，请稍后！");
        progressDialog.show();
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (searchReceiver != null) {
            //取消注册,防止内存泄露（onDestroy被回调代不代表Activity被回收
            //管理的ams中，即使activity被回收，reciver也不会被回收，所以一定要取消注册
            unregisterReceiver(searchReceiver);
        }
    }

}

    @Override
    public boolean Linten(View v, MotionEvent event) {/
        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                x= (int) (event.getX());
                y= (int) (event.getY());
                xSearch = (int) event.getX();//根据响应进行获取
                ySearch = (int) event.getY();
                mParams.setMargins(xSearch, ySearch, 0, 0);
                mImageView.get(j).setLayoutParams(mParams);
                mImageView.add(j,new ImageView(SearchMyCar.this));
                relativeLayout.addView(mImageView.get(j));//展示位置
                break;
            case MotionEvent.ACTION_MOVE:
                break;
            default:
                break;
        }
        return true;
    }
