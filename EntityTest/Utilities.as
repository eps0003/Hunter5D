u16 getUniqueId()
{
	return getRules().addu16("_id", 1);
}
