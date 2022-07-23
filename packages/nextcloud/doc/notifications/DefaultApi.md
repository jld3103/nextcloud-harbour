# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://localhost:8080/ocs/v1.php/apps/notifications*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAllNotifications**](DefaultApi.md#deleteallnotifications) | **DELETE** /api/v2/notifications | 
[**deleteNotification**](DefaultApi.md#deletenotification) | **DELETE** /api/v2/notifications/{id} | 
[**getNotification**](DefaultApi.md#getnotification) | **GET** /api/v2/notifications/{id} | 
[**listNotifications**](DefaultApi.md#listnotifications) | **GET** /api/v2/notifications | 
[**registerDevice**](DefaultApi.md#registerdevice) | **POST** /api/v2/push | 
[**removeDevice**](DefaultApi.md#removedevice) | **DELETE** /api/v2/push | 
[**sendAdminNotification**](DefaultApi.md#sendadminnotification) | **POST** /api/v2/admin_notifications/{userId} | 


# **deleteAllNotifications**
> String deleteAllNotifications()



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();

try {
    final result = api_instance.deleteAllNotifications();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->deleteAllNotifications: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNotification**
> NotificationsEmptyResponse deleteNotification(id)



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();
final id = 56; // int | 

try {
    final result = api_instance.deleteNotification(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->deleteNotification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**NotificationsEmptyResponse**](NotificationsEmptyResponse.md)

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNotification**
> NotificationsGetNotificationResponse getNotification(id)



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();
final id = 56; // int | 

try {
    final result = api_instance.getNotification(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getNotification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**NotificationsGetNotificationResponse**](NotificationsGetNotificationResponse.md)

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNotifications**
> NotificationsListNotificationsResponse listNotifications()



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();

try {
    final result = api_instance.listNotifications();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listNotifications: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NotificationsListNotificationsResponse**](NotificationsListNotificationsResponse.md)

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDevice**
> NotificationsPushServerRegistrationResponse registerDevice(notificationsPushServerDevice)



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();
final notificationsPushServerDevice = NotificationsPushServerDevice(); // NotificationsPushServerDevice | 

try {
    final result = api_instance.registerDevice(notificationsPushServerDevice);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->registerDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notificationsPushServerDevice** | [**NotificationsPushServerDevice**](NotificationsPushServerDevice.md)|  | 

### Return type

[**NotificationsPushServerRegistrationResponse**](NotificationsPushServerRegistrationResponse.md)

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeDevice**
> String removeDevice()



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();

try {
    final result = api_instance.removeDevice();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->removeDevice: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendAdminNotification**
> NotificationsEmptyResponse sendAdminNotification(userId, notificationsAdminNotification)



### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP basic authorization: basic_auth
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').username = 'YOUR_USERNAME'
//defaultApiClient.getAuthentication<HttpBasicAuth>('basic_auth').password = 'YOUR_PASSWORD';

final api_instance = DefaultApi();
final userId = userId_example; // String | 
final notificationsAdminNotification = NotificationsAdminNotification(); // NotificationsAdminNotification | 

try {
    final result = api_instance.sendAdminNotification(userId, notificationsAdminNotification);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sendAdminNotification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **notificationsAdminNotification** | [**NotificationsAdminNotification**](NotificationsAdminNotification.md)|  | 

### Return type

[**NotificationsEmptyResponse**](NotificationsEmptyResponse.md)

### Authorization

[basic_auth](../README.md#basic_auth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

