#include "ModelAnimation.as"

shared class PhysicalActorRunAnim : ModelAnimation
{
	private PhysicalActor@ actor;

	private ModelSegment@ body;
	private ModelSegment@ head;
	private ModelSegment@ upperLeftArm;
	private ModelSegment@ upperRightArm;
	private ModelSegment@ lowerLeftArm;
	private ModelSegment@ lowerRightArm;
	private ModelSegment@ upperLeftLeg;
	private ModelSegment@ upperRightLeg;
	private ModelSegment@ lowerLeftLeg;
	private ModelSegment@ lowerRightLeg;

	private float maxHeadAngle = 60.0f;

	PhysicalActorRunAnim(PhysicalActor@ actor, ActorModel@ model)
	{
		@this.actor = actor;

		@body = model.getSegment("body");
		@head = model.getSegment("head");
		@upperLeftArm = model.getSegment("upperLeftArm");
		@upperRightArm = model.getSegment("upperRightArm");
		@lowerLeftArm = model.getSegment("lowerLeftArm");
		@lowerRightArm = model.getSegment("lowerRightArm");
		@upperLeftLeg = model.getSegment("upperLeftLeg");
		@upperRightLeg = model.getSegment("upperRightLeg");
		@lowerLeftLeg = model.getSegment("lowerLeftLeg");
		@lowerRightLeg = model.getSegment("lowerRightLeg");
	}

	void Animate(float t)
	{
		float rt = t * Maths::Pi * 2.0f;

		Vec2f velXZ = actor.interVelocity.toXZ();
		float vel = velXZ.Length() * 5.0f;

		float sin = Maths::Sin(rt) * vel;
		float cos = Maths::Cos(rt) * vel;

		float limbSin = sin * 40.0f;
		float limbCos = cos * 40.0f;

		body.offset = Vec3f(0, Maths::Abs(cos * 0.1f) * vel * 1.5f, 0) + actor.interPosition;
		body.rotation = Vec3f(-4.0f * vel + Maths::Sin(rt * 2.0f) * vel * -4.0f, -velXZ.Angle() - 90, cos);

		float diff = Maths::AngleDifference(actor.interRotation.y, body.rotation.y);
		if (Maths::Abs(diff) > maxHeadAngle)
		{
			body.rotation.y = actor.rotation.y + maxHeadAngle * Maths::Sign(diff);
		}

		head.rotation = actor.interRotation + Vec3f(Maths::Sin(rt * 2.0f) * vel * 4.0f, -body.rotation.y, 0);

		upperLeftArm.rotation = Vec3f(-limbCos, 0, 0);
		upperRightArm.rotation = Vec3f(limbCos, 0, 0);

		lowerLeftArm.rotation = Vec3f(Maths::Max(0, -limbCos), 0, 0);
		lowerRightArm.rotation = Vec3f(Maths::Max(0, limbCos), 0, 0);

		upperLeftLeg.rotation = Vec3f(limbCos, 0, 0);
		upperRightLeg.rotation = Vec3f(-limbCos, 0, 0);

		lowerLeftLeg.rotation = Vec3f(Maths::Min(0, limbSin), 0, 0);
		lowerRightLeg.rotation = Vec3f(Maths::Min(0, -limbSin), 0, 0);
	}
}
